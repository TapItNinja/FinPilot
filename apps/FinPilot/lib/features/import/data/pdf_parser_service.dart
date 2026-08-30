// lib/features/import/data/pdf_parser_service.dart
//
// Orchestrates PDF import:
// 1. Pick file via file_picker
// 2. Extract text via syncfusion_flutter_pdf
// 3. Detect bank from text
// 4. Parse transactions using bank-specific parser
// 5. Run duplicate detection against existing transactions
// 6. Return results for the review screen

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'bank_parsers/hdfc_parser.dart';
import 'bank_parsers/sbi_parser.dart';
import 'bank_parsers/icici_parser.dart';
import 'bank_parsers/axis_parser.dart';

// ── Bank parser interface ─────────────────────────────────────────────────────
// Every bank parser implements this.
// Adding a new bank = create a new class implementing BankParser.
abstract class BankParser {
  String get bankName;
  bool canParse(String rawText);
  List<ParsedTransaction> parse(String rawText);
}

// ── Parsed transaction (before becoming TransactionEntity) ────────────────────
// Intermediate model — doesn't have accountId or rule engine tags yet.
class ParsedTransaction {
  final String merchant;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? referenceNumber;
  final String rawNarration;
  final String bankName;

  // Set during duplicate detection
  final bool isDuplicateCandidate;
  final String? duplicateReason;

  const ParsedTransaction({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.type,
    required this.rawNarration,
    required this.bankName,
    this.referenceNumber,
    this.isDuplicateCandidate = false,
    this.duplicateReason,
  });

  ParsedTransaction copyWith({
    bool? isDuplicateCandidate,
    String? duplicateReason,
  }) {
    return ParsedTransaction(
      merchant: merchant,
      amount: amount,
      date: date,
      type: type,
      referenceNumber: referenceNumber,
      rawNarration: rawNarration,
      bankName: bankName,
      isDuplicateCandidate: isDuplicateCandidate ?? this.isDuplicateCandidate,
      duplicateReason: duplicateReason ?? this.duplicateReason,
    );
  }

  // Convert to TransactionEntity for saving
  TransactionEntity toEntity({
    required String accountId,
    required String accountName,
  }) {
    return TransactionEntity(
      id: '${date.millisecondsSinceEpoch}_${merchant.hashCode}_${amount.hashCode}',
      amount: amount,
      currencyCode: CurrencyCode.inr,
      merchant: merchant,
      timestamp: date,
      category: 'Uncategorized', // rule engine will fill this
      type: type,
      source: accountName,
      accountId: accountId,
      status: TransactionStatus.completed,
      isRecurring: false,
      referenceNumber: referenceNumber,
      importSource: ImportSource.pdf,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// ── Import result ─────────────────────────────────────────────────────────────
class PdfImportResult {
  final String bankName;
  final String fileName;
  final List<ParsedTransaction> transactions;
  final int duplicateCount;
  final String? error;

  const PdfImportResult({
    required this.bankName,
    required this.fileName,
    required this.transactions,
    required this.duplicateCount,
    this.error,
  });

  bool get hasError => error != null;
  int get newCount => transactions.where((t) => !t.isDuplicateCandidate).length;
}

// ── PDF Parser Service ────────────────────────────────────────────────────────
class PdfParserService {
  // All registered bank parsers — add new banks here
  final List<BankParser> _parsers = [
    HdfcParser(),
    SbiParser(),
    IciciParser(),
    AxisParser(),
  ];

  // Step 1: Pick a PDF file
  // Returns null if user cancelled
  Future<PlatformFile?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true, // load bytes into memory for syncfusion
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }
    return result.files.first;
  }

  // Step 2: Extract text from PDF (with optional password)
  // Returns null if extraction failed
  Future<String?> extractText(PlatformFile file, {String? password}) async {
    try {
      late PdfDocument document;

      if (file.bytes != null) {
        // Use bytes if available (mobile)
        document = password != null && password.isNotEmpty
            ? PdfDocument(inputBytes: file.bytes!, password: password)
            : PdfDocument(inputBytes: file.bytes!);
      } else if (file.path != null) {
        // Fallback to path (desktop)
        final bytes = await File(file.path!).readAsBytes();
        document = password != null && password.isNotEmpty
            ? PdfDocument(inputBytes: bytes, password: password)
            : PdfDocument(inputBytes: bytes);
      } else {
        return null;
      }

      // Extract text from all pages
      final extractor = PdfTextExtractor(document);
      final buffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        buffer.writeln(pageText);
      }

      document.dispose();
      return buffer.toString();
    } catch (e) {
      // Wrong password or corrupted PDF
      return null;
    }
  }

  // Step 3: Detect bank and parse transactions
  PdfImportResult parseText(
    String rawText,
    String fileName,
    List<TransactionEntity> existingTransactions,
  ) {
    // Find the right parser
    BankParser? parser;
    for (final p in _parsers) {
      if (p.canParse(rawText)) {
        parser = p;
        break;
      }
    }

    if (parser == null) {
      return PdfImportResult(
        bankName: 'Unknown',
        fileName: fileName,
        transactions: [],
        duplicateCount: 0,
        error:
            'Could not detect bank format. Currently supported: HDFC, SBI, ICICI, Axis.',
      );
    }

    // Parse transactions
    final parsed = parser.parse(rawText);

    if (parsed.isEmpty) {
      return PdfImportResult(
        bankName: parser.bankName,
        fileName: fileName,
        transactions: [],
        duplicateCount: 0,
        error:
            'No transactions found. The statement may use an unsupported format.',
      );
    }

    // Run duplicate detection
    final withDuplicates = _detectDuplicates(parsed, existingTransactions);
    final duplicateCount = withDuplicates
        .where((t) => t.isDuplicateCandidate)
        .length;

    return PdfImportResult(
      bankName: parser.bankName,
      fileName: fileName,
      transactions: withDuplicates,
      duplicateCount: duplicateCount,
    );
  }

  // ── Duplicate detection ───────────────────────────────────────────────────
  // Three-layer approach:
  // 1. Reference number exact match → definite duplicate
  // 2. Amount + merchant + date (±1 day) → probable duplicate
  // 3. Amount + date exact match → possible duplicate
  List<ParsedTransaction> _detectDuplicates(
    List<ParsedTransaction> parsed,
    List<TransactionEntity> existing,
  ) {
    return parsed.map((transaction) {
      // Layer 1: Reference number match
      if (transaction.referenceNumber != null) {
        final hasRef = existing.any(
          (e) => e.referenceNumber == transaction.referenceNumber,
        );
        if (hasRef) {
          return transaction.copyWith(
            isDuplicateCandidate: true,
            duplicateReason: 'Same reference number',
          );
        }
      }

      // Layer 2: Amount + merchant + date (±1 day)
      final fuzzyMatch = existing.any((e) {
        final sameAmount = e.amount == transaction.amount;
        final similarMerchant = _merchantsSimilar(
          e.merchant,
          transaction.merchant,
        );
        final sameDay = _withinDays(e.timestamp, transaction.date, 1);
        return sameAmount && similarMerchant && sameDay;
      });

      if (fuzzyMatch) {
        return transaction.copyWith(
          isDuplicateCandidate: true,
          duplicateReason: 'Similar transaction already exists',
        );
      }

      // Layer 3: Exact amount + exact date
      final exactMatch = existing.any((e) {
        return e.amount == transaction.amount &&
            e.timestamp.year == transaction.date.year &&
            e.timestamp.month == transaction.date.month &&
            e.timestamp.day == transaction.date.day &&
            e.type == transaction.type;
      });

      if (exactMatch) {
        return transaction.copyWith(
          isDuplicateCandidate: true,
          duplicateReason: 'Same amount on same date',
        );
      }

      return transaction;
    }).toList();
  }

  // Check if two merchant names are similar (handles abbreviations)
  bool _merchantsSimilar(String a, String b) {
    final aLower = a.toLowerCase().trim();
    final bLower = b.toLowerCase().trim();

    if (aLower == bLower) {
      return true;
    }

    // Check if one contains the other (handles "Swiggy" vs "Swiggy Infotech")
    if (aLower.contains(bLower) || bLower.contains(aLower)) {
      return true;
    }

    // Check first word match (handles "Amazon Pay" vs "Amazon")
    final aFirst = aLower.split(' ').first;
    final bFirst = bLower.split(' ').first;
    if (aFirst == bFirst && aFirst.length > 3) {
      return true;
    }

    return false;
  }

  bool _withinDays(DateTime a, DateTime b, int days) {
    return a.difference(b).inDays.abs() <= days;
  }
}

final pdfParserServiceProvider = Provider<PdfParserService>(
  (ref) => PdfParserService(),
);
