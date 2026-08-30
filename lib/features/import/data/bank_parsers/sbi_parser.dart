// lib/features/import/data/bank_parsers/sbi_parser.dart
//
// Parses SBI (State Bank of India) PDF statements.
// SBI format:
// Txn Date    Value Date    Description                          Ref No./Cheque No.   Debit    Credit   Balance
// 01 May 2026 01 May 2026   TO TRANSFER-UPI/DR/123/SWIGGY        123456789           249.00            44751.00

import '../pdf_parser_service.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class SbiParser implements BankParser {
  @override
  String get bankName => 'State Bank of India';

  @override
  bool canParse(String rawText) {
    final lower = rawText.toLowerCase();
    return lower.contains('state bank of india') ||
        lower.contains('sbi') && lower.contains('account statement') ||
        lower.contains('onlinesbi');
  }

  @override
  List<ParsedTransaction> parse(String rawText) {
    final transactions = <ParsedTransaction>[];
    final lines = rawText.split('\n');

    // SBI date: dd Mon yyyy (e.g. 01 May 2026)
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

      // SBI lines often start with transaction date
      final dateMatches = datePattern.allMatches(trimmed).toList();
      if (dateMatches.isEmpty) {
        continue;
      }

      final date = _parseDateWords(dateMatches.first.group(1)!);
      if (date == null) {
        continue;
      }

      // Get all amounts on line
      final amounts = amountPattern.allMatches(trimmed).toList();
      if (amounts.isEmpty) {
        continue;
      }

      // Extract description — between dates and amounts
      String description = trimmed;
      for (final m in dateMatches) {
        description = description.replaceAll(m.group(1)!, '');
      }
      for (final m in amounts) {
        description = description.replaceAll(m.group(1)!, '');
      }
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (description.isEmpty) {
        continue;
      }

      // SBI: debit column comes before credit column
      // Last 2 amounts before balance: debit, credit (one will be empty)
      // We detect by looking at "TO TRANSFER" = debit, "BY TRANSFER" = credit
      final isCredit =
          description.toUpperCase().startsWith('BY') ||
          description.toLowerCase().contains('credit') ||
          description.toLowerCase().contains('salary') ||
          description.toLowerCase().contains('interest');

      // Use first amount for the transaction value
      final amount = _parseAmount(amounts.first.group(1)!);
      if (amount == null || amount <= 0) {
        continue;
      }

      // Extract reference number
      final refPattern = RegExp(r'\b(\d{8,15})\b');
      final refMatch = refPattern.firstMatch(description);

      transactions.add(
        ParsedTransaction(
          merchant: _extractMerchant(description),
          amount: amount,
          date: date,
          type: isCredit ? TransactionType.credit : TransactionType.debit,
          referenceNumber: refMatch?.group(1),
          rawNarration: description,
          bankName: bankName,
        ),
      );
    }

    return transactions;
  }

  String _extractMerchant(String description) {
    // SBI UPI: UPI/DR/123456/MERCHANT_NAME or UPI/CR/123/SENDER
    final upiPattern = RegExp(
      r'UPI/(?:DR|CR)/\d+/([^/\s]+)',
      caseSensitive: false,
    );
    final upiMatch = upiPattern.firstMatch(description);
    if (upiMatch != null) {
      return _titleCase(upiMatch.group(1)!.replaceAll('_', ' '));
    }

    // IMPS/NEFT
    if (description.toUpperCase().contains('IMPS') ||
        description.toUpperCase().contains('NEFT')) {
      final parts = description.split('/');
      if (parts.length >= 3) {
        return _titleCase(parts.last.trim());
      }
    }

    // ATM
    if (description.toUpperCase().contains('ATM') ||
        description.toUpperCase().contains('ATW')) {
      return 'ATM Withdrawal';
    }

    // Remove SBI prefixes (TO TRANSFER-, BY TRANSFER-, etc.)
    String cleaned = description
        .replaceAll(
          RegExp(r'^(TO|BY)\s+TRANSFER[\-\s]*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'^(TO|BY)\s+', caseSensitive: false), '')
        .trim();

    final words = cleaned.split(' ').where((w) => w.length > 2).toList();
    if (words.isEmpty) {
      return description;
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
