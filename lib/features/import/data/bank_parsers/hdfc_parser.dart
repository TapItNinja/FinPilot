// lib/features/import/data/bank_parsers/hdfc_parser.dart
//
// Parses HDFC Bank PDF statements.
// HDFC statement format:
// Date        Narration                    Chq/Ref No.   Value Date   Withdrawal   Deposit   Closing Balance
// 01/05/2026  UPI-SWIGGY-9876543210       123456789     01/05/2026   249.00                 45,000.00
//
// HDFC credit card statement format is different — handled separately below.
import '../pdf_parser_service.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class HdfcParser implements BankParser {
  @override
  String get bankName => 'HDFC Bank';

  // Detect if this PDF is an HDFC statement
  @override
  bool canParse(String rawText) {
    final lower = rawText.toLowerCase();
    return lower.contains('hdfc bank') ||
        lower.contains('hdfcbank') ||
        lower.contains('hdfc credit card');
  }

  @override
  List<ParsedTransaction> parse(String rawText) {
    final isCreditCard =
        rawText.toLowerCase().contains('hdfc credit card') ||
        rawText.toLowerCase().contains('credit card statement');

    if (isCreditCard) {
      return _parseCreditCard(rawText);
    }
    return _parseSavings(rawText);
  }

  // ── HDFC Savings/Current account ─────────────────────────────────────────
  List<ParsedTransaction> _parseSavings(String rawText) {
    final transactions = <ParsedTransaction>[];
    final lines = rawText.split('\n');

    // HDFC date pattern: dd/mm/yyyy or dd-mm-yyyy
    final datePattern = RegExp(r'(\d{2}[/\-]\d{2}[/\-]\d{4})');
    // Amount pattern: numbers with optional commas and 2 decimal places
    final amountPattern = RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        continue;
      }

      final dateMatch = datePattern.firstMatch(line);
      if (dateMatch == null) {
        continue;
      }

      final dateStr = dateMatch.group(1)!;
      final date = _parseDate(dateStr);
      if (date == null) {
        continue;
      }

      // Extract amounts from the line
      final amounts = amountPattern.allMatches(line).toList();
      if (amounts.isEmpty) {
        continue;
      }

      // Extract narration — text between date and first amount
      final dateEnd = dateMatch.end;
      final firstAmountStart = amounts.first.start;
      if (firstAmountStart <= dateEnd) {
        continue;
      }

      String narration = line.substring(dateEnd, firstAmountStart).trim();
      narration = _cleanNarration(narration);
      if (narration.isEmpty) {
        continue;
      }

      // HDFC savings: withdrawal = debit, deposit = credit
      // Last 2-3 amounts on line: withdrawal, deposit, closing balance
      // If withdrawal column has value → debit, if deposit → credit
      double? withdrawal;
      double? deposit;

      if (amounts.length >= 2) {
        // Try to determine debit vs credit by position in line
        // Withdrawal comes before deposit in HDFC format
        final lineAfterDate = line.substring(dateEnd);
        final isDebit =
            lineAfterDate.contains(amounts.first.group(1)!) &&
            _isWithdrawal(line, amounts, rawText);

        final amount = _parseAmount(amounts.first.group(1)!);
        if (amount == null || amount <= 0) {
          continue;
        }

        if (isDebit) {
          withdrawal = amount;
        } else {
          deposit = amount;
        }
      } else if (amounts.length == 1) {
        // Single amount — check context for debit/credit
        final amount = _parseAmount(amounts.first.group(1)!);
        if (amount == null || amount <= 0) {
          continue;
        }
        // Default to debit if unclear
        withdrawal = amount;
      }

      final amount = withdrawal ?? deposit;
      if (amount == null || amount <= 0) {
        continue;
      }

      final type = withdrawal != null
          ? TransactionType.debit
          : TransactionType.credit;

      // Extract reference number if present
      final refPattern = RegExp(r'\b(\d{10,15})\b');
      final refMatch = refPattern.firstMatch(narration);
      final refNumber = refMatch?.group(1);

      transactions.add(
        ParsedTransaction(
          merchant: _extractMerchant(narration),
          amount: amount,
          date: date,
          type: type,
          referenceNumber: refNumber,
          rawNarration: narration,
          bankName: bankName,
        ),
      );
    }

    return transactions;
  }

  // ── HDFC Credit Card ──────────────────────────────────────────────────────
  List<ParsedTransaction> _parseCreditCard(String rawText) {
    final transactions = <ParsedTransaction>[];
    final lines = rawText.split('\n');

    // Credit card date: dd MMM yyyy (e.g. 01 May 2026)
    final datePattern = RegExp(
      r'(\d{2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{4})',
      caseSensitive: false,
    );
    final amountPattern = RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final dateMatch = datePattern.firstMatch(trimmed);
      if (dateMatch == null) {
        continue;
      }

      final date = _parseDateWords(dateMatch.group(1)!);
      if (date == null) {
        continue;
      }

      final amounts = amountPattern.allMatches(trimmed).toList();
      if (amounts.isEmpty) {
        continue;
      }

      final narration = trimmed
          .replaceAll(dateMatch.group(1)!, '')
          .replaceAll(amounts.last.group(1)!, '')
          .trim();

      final amount = _parseAmount(amounts.last.group(1)!);
      if (amount == null || amount <= 0) {
        continue;
      }

      // Credit card: most transactions are debits (purchases)
      // Credits are refunds/payments — look for Cr suffix
      final isCredit =
          trimmed.toLowerCase().contains(' cr') ||
          trimmed.toLowerCase().contains('refund') ||
          trimmed.toLowerCase().contains('payment received');

      transactions.add(
        ParsedTransaction(
          merchant: _extractMerchant(narration),
          amount: amount,
          date: date,
          type: isCredit ? TransactionType.credit : TransactionType.debit,
          rawNarration: narration,
          bankName: bankName,
        ),
      );
    }

    return transactions;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isWithdrawal(String line, List<RegExpMatch> amounts, String fullText) {
    // Simple heuristic: if the column header says "Withdrawal" before "Deposit"
    // and this amount is in the withdrawal column position
    final headerIndex = fullText.toLowerCase().indexOf('withdrawal');
    final depositIndex = fullText.toLowerCase().indexOf('deposit');
    if (headerIndex == -1 || depositIndex == -1) {
      return true;
    }
    // Default to debit for most UPI/card transactions
    return true;
  }

  String _cleanNarration(String narration) {
    // Remove extra spaces, special chars
    return narration
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\-/]'), '')
        .trim();
  }

  String _extractMerchant(String narration) {
    // UPI transactions: UPI-MERCHANT_NAME-phone
    if (narration.toUpperCase().startsWith('UPI-')) {
      final parts = narration.split('-');
      if (parts.length >= 2) {
        return _titleCase(parts[1].trim());
      }
    }

    // NEFT/RTGS: NEFT CR/DR BANK NAME
    if (narration.toUpperCase().startsWith('NEFT') ||
        narration.toUpperCase().startsWith('RTGS')) {
      final parts = narration.split(' ');
      if (parts.length >= 3) {
        return _titleCase(parts.sublist(2).join(' ').trim());
      }
    }

    // ATM: ATW/ATM followed by location
    if (narration.toUpperCase().contains('ATW') ||
        narration.toUpperCase().contains('ATM')) {
      return 'ATM Withdrawal';
    }

    // Default: take first meaningful words
    final words = narration.split(' ').where((w) => w.length > 2).toList();
    if (words.isEmpty) {
      return narration;
    }
    return _titleCase(words.take(3).join(' '));
  }

  String _titleCase(String s) {
    return s
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  double? _parseAmount(String s) {
    return double.tryParse(s.replaceAll(',', ''));
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(RegExp(r'[/\-]'));
      if (parts.length != 3) {
        return null;
      }
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDateWords(String dateStr) {
    try {
      final parts = dateStr.trim().split(RegExp(r'\s+'));
      if (parts.length != 3) {
        return null;
      }
      final day = int.parse(parts[0]);
      final month = _monthNumber(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  int _monthNumber(String abbr) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return months[abbr.toLowerCase()] ?? 1;
  }
}
