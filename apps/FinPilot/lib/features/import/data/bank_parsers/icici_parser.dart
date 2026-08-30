// lib/features/import/data/bank_parsers/icici_parser.dart
//
// Parses ICICI Bank PDF statements.
// ICICI savings format:
// S No. Value Date  Transaction Date  Cheque Number  Transaction Remarks         Withdrawal(Dr)  Deposit(Cr)  Balance
// 1     01/05/2026  01/05/2026                       UPI/P2M/123456/SWIGGY       249.00                       44751.00
//
// ICICI credit card:
// Date         Transaction Details                      Amount(in Rs.)
// 01/05/2026   SWIGGY ORDER 123456                      249.00

import '../pdf_parser_service.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class IciciParser implements BankParser {
  @override
  String get bankName => 'ICICI Bank';

  @override
  bool canParse(String rawText) {
    final lower = rawText.toLowerCase();
    return lower.contains('icici bank') ||
        lower.contains('icicibank') ||
        lower.contains('icici credit card');
  }

  @override
  List<ParsedTransaction> parse(String rawText) {
    final isCreditCard =
        rawText.toLowerCase().contains('icici credit card') ||
        rawText.toLowerCase().contains('credit card statement');

    if (isCreditCard) {
      return _parseCreditCard(rawText);
    }
    return _parseSavings(rawText);
  }

  List<ParsedTransaction> _parseSavings(String rawText) {
    final transactions = <ParsedTransaction>[];
    final lines = rawText.split('\n');

    // ICICI date: dd/mm/yyyy
    final datePattern = RegExp(r'(\d{2}/\d{2}/\d{4})');
    final amountPattern = RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final dateMatches = datePattern.allMatches(trimmed).toList();
      if (dateMatches.isEmpty) {
        continue;
      }

      final date = _parseDate(dateMatches.first.group(1)!);
      if (date == null) {
        continue;
      }

      final amounts = amountPattern.allMatches(trimmed).toList();
      if (amounts.isEmpty) {
        continue;
      }

      // Extract description
      String description = trimmed;
      for (final m in dateMatches) {
        description = description.replaceAll(m.group(1)!, '');
      }
      for (final m in amounts) {
        description = description.replaceAll(m.group(1)!, '');
      }
      // Remove serial numbers at start
      description = description.replaceAll(RegExp(r'^\d+\s*'), '').trim();
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (description.isEmpty || description.length < 3) {
        continue;
      }

      // ICICI: Withdrawal(Dr) before Deposit(Cr)
      // Check description for credit indicators
      final isCredit =
          description.toUpperCase().contains('UPI/P2A') ||
          description.toLowerCase().contains('salary') ||
          description.toLowerCase().contains('credit') ||
          description.toUpperCase().contains('NEFT CR') ||
          _isDepositDescription(description);

      final amount = _parseAmount(amounts.first.group(1)!);
      if (amount == null || amount <= 0) {
        continue;
      }

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

  List<ParsedTransaction> _parseCreditCard(String rawText) {
    final transactions = <ParsedTransaction>[];
    final lines = rawText.split('\n');

    final datePattern = RegExp(r'(\d{2}/\d{2}/\d{4})');
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

      final date = _parseDate(dateMatch.group(1)!);
      if (date == null) {
        continue;
      }

      final amounts = amountPattern.allMatches(trimmed).toList();
      if (amounts.isEmpty) {
        continue;
      }

      String description = trimmed
          .replaceAll(dateMatch.group(1)!, '')
          .replaceAll(amounts.last.group(1)!, '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (description.isEmpty) {
        continue;
      }

      final amount = _parseAmount(amounts.last.group(1)!);
      if (amount == null || amount <= 0) {
        continue;
      }

      final isCredit =
          trimmed.toLowerCase().contains('cr') ||
          trimmed.toLowerCase().contains('refund') ||
          trimmed.toLowerCase().contains('reversal');

      transactions.add(
        ParsedTransaction(
          merchant: _extractMerchant(description),
          amount: amount,
          date: date,
          type: isCredit ? TransactionType.credit : TransactionType.debit,
          rawNarration: description,
          bankName: bankName,
        ),
      );
    }

    return transactions;
  }

  bool _isDepositDescription(String desc) {
    final upper = desc.toUpperCase();
    return upper.contains('INTEREST') ||
        upper.contains('DIVIDEND') ||
        upper.contains('REFUND');
  }

  String _extractMerchant(String description) {
    // ICICI UPI: UPI/P2M/123456/MERCHANT or UPI/P2A/123/SENDER
    final upiPattern = RegExp(
      r'UPI/P2[MA]/\d+/([^/\s]+)',
      caseSensitive: false,
    );
    final upiMatch = upiPattern.firstMatch(description);
    if (upiMatch != null) {
      return _titleCase(upiMatch.group(1)!.replaceAll('_', ' '));
    }

    // Remove common ICICI prefixes
    String cleaned = description
        .replaceAll(
          RegExp(r'^(NEFT|RTGS|IMPS)[/\-\s]*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'^(CR|DR)[/\-\s]*', caseSensitive: false), '')
        .trim();

    if (cleaned.isEmpty) {
      return description;
    }

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

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) {
        return null;
      }
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }
}
