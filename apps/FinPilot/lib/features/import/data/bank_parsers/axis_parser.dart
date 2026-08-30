// lib/features/import/data/bank_parsers/axis_parser.dart
//
// Parses Axis Bank PDF statements.
// Axis savings format:
// Tran Date    Chq No    Particulars                     Debit     Credit    Balance
// 01-05-2026             UPI/123456789/SWIGGY INFOTECH   249.00              44751.00

import '../pdf_parser_service.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class AxisParser implements BankParser {
  @override
  String get bankName => 'Axis Bank';

  @override
  bool canParse(String rawText) {
    final lower = rawText.toLowerCase();
    return lower.contains('axis bank') ||
        lower.contains('axisbank') ||
        lower.contains('axis credit card');
  }

  @override
  List<ParsedTransaction> parse(String rawText) {
    final transactions = <ParsedTransaction>[];
    final lines = rawText.split('\n');

    // Axis date: dd-mm-yyyy or dd/mm/yyyy
    final datePattern = RegExp(r'(\d{2}[\-/]\d{2}[\-/]\d{4})');
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

      String description = trimmed.substring(dateMatch.end).trim();

      // Remove amounts from description
      for (final m in amounts) {
        description = description.replaceAll(m.group(1)!, '');
      }
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (description.isEmpty || description.length < 3) {
        continue;
      }

      // Axis: debit column before credit
      // Check for credit indicators
      final isCredit =
          description.toLowerCase().contains('credit') ||
          description.toLowerCase().contains('salary') ||
          description.toUpperCase().contains('NEFT CR') ||
          description.toLowerCase().contains('interest') ||
          description.toLowerCase().contains('refund');

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

  String _extractMerchant(String description) {
    // Axis UPI: UPI/123456789/MERCHANT NAME
    final upiPattern = RegExp(r'UPI/\d+/([^/\n]+)', caseSensitive: false);
    final upiMatch = upiPattern.firstMatch(description);
    if (upiMatch != null) {
      final merchant = upiMatch.group(1)!.trim();
      return _titleCase(merchant.split(' ').take(3).join(' '));
    }

    // NEFT/RTGS/IMPS
    if (description.toUpperCase().contains('NEFT') ||
        description.toUpperCase().contains('RTGS') ||
        description.toUpperCase().contains('IMPS')) {
      final parts = description.split('/');
      if (parts.length >= 2) {
        return _titleCase(parts.last.trim().split(' ').take(2).join(' '));
      }
    }

    // ATM
    if (description.toUpperCase().contains('ATM')) {
      return 'ATM Withdrawal';
    }

    final words = description.split(' ').where((w) => w.length > 2).toList();
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
      final parts = dateStr.split(RegExp(r'[\-/]'));
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
