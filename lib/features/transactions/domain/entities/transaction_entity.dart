// WHY THIS FILE EXISTS:
// TransactionEntity is the single source of truth for what a "transaction" means in this app.
// Every feature — import, analytics, budgets, AI insights — works with this object.
// The domain layer (this file) has NO dependency on Flutter, Hive, or any external package.
// It's pure Dart. This means it's easy to test and easy to move if we change our storage layer.
//lib/features/transactions/domain/entities/transaction_entity.dart
enum TransactionType { credit, debit, transfer, refund }

enum TransactionStatus { pending, completed, failed, cancelled, reversed }

enum CurrencyCode { usd, eur, inr, gbp }

// NEW: Tracks how the transaction entered the app.
// This helps us show the user where data came from and debug parser issues.
enum ImportSource { manual, email, pdf, plaid, unknown }

// NEW: Whether the account is savings/current (shown as XXXXX1234 in alerts)
// or credit (shown as XX1234 in alerts). We use this to segment account data.
enum AccountType { savings, credit, unknown }

class TransactionEntity {
  final String id;
  final double amount;
  final CurrencyCode currencyCode;
  final double? convertedAmount;
  final String merchant;
  final String? merchantLogoUrl;
  final DateTime timestamp;
  final String category;
  final String? subcategory;
  final TransactionType type;
  final String source; // human-readable account name e.g. "HDFC Savings"
  final TransactionStatus status;
  final String? referenceNumber;
  final String? note;
  final List<String>? tags;
  final String? accountId;
  final String? transferToAccountId;
  final bool isRecurring;
  final double? balanceAfter;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // --- NEW FIELDS ---

  // Where did this transaction come from? manual entry, email parse, pdf upload, etc.
  // Defaults to unknown so existing dummy data doesn't break.
  final ImportSource importSource;

  // Last 4 digits of the account number extracted from bank alerts.
  // XXXXX1234 (debit) → '1234', XX1234 (credit) → '1234'
  // We store just the 4 digits — the prefix pattern tells us the account type.
  final String? accountLast4;

  // Whether this account is savings or credit.
  // Determined during import by looking at the alert format (XXXXX vs XX prefix).
  final AccountType accountType;

  // Auto-tags applied by the RuleEngine (e.g. ['Food'] from rule: KFC → Food).
  // Stored as a list because a single merchant could match multiple rules in future.
  // Separate from user-defined `tags` so we don't overwrite what the user set manually.
  final List<String>? autoTags;

  // EMI tracking. When we detect a large debit, we prompt the user.
  // If they confirm it's EMI, we store the details here.
  final bool isEmi;
  final int? emiMonthsTotal; // how many months total (e.g. 12)
  final int? emiMonthsRemaining; // how many months left
  final double? emiMonthlyAmount; // per-month deduction amount

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.currencyCode,
    required this.merchant,
    required this.timestamp,
    required this.category,
    required this.type,
    required this.source,
    required this.status,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,

    this.convertedAmount,
    this.merchantLogoUrl,
    this.subcategory,
    this.referenceNumber,
    this.note,
    this.tags,
    this.accountId,
    this.transferToAccountId,
    this.balanceAfter,
    this.metadata,

    // New fields are optional with safe defaults so existing code doesn't break.
    this.importSource = ImportSource.unknown,
    this.accountLast4,
    this.accountType = AccountType.unknown,
    this.autoTags,
    this.isEmi = false,
    this.emiMonthsTotal,
    this.emiMonthsRemaining,
    this.emiMonthlyAmount,
  });

  // WHY copyWith:
  // All fields are final (immutable). You can't do transaction.autoTags = ['Food'].
  // Instead, copyWith creates a NEW TransactionEntity with most fields copied from
  // the original, but with specific ones overridden.
  //
  // Usage example in RuleEngine:
  //   return transaction.copyWith(autoTags: ['Food', 'Dining']);
  //
  // The ?? operator means: "use the new value if provided, otherwise keep the original."
  TransactionEntity copyWith({
    String? id,
    double? amount,
    CurrencyCode? currencyCode,
    double? convertedAmount,
    String? merchant,
    String? merchantLogoUrl,
    DateTime? timestamp,
    String? category,
    String? subcategory,
    TransactionType? type,
    String? source,
    TransactionStatus? status,
    String? referenceNumber,
    String? note,
    List<String>? tags,
    String? accountId,
    String? transferToAccountId,
    bool? isRecurring,
    double? balanceAfter,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    ImportSource? importSource,
    String? accountLast4,
    AccountType? accountType,
    List<String>? autoTags,
    bool? isEmi,
    int? emiMonthsTotal,
    int? emiMonthsRemaining,
    double? emiMonthlyAmount,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      merchant: merchant ?? this.merchant,
      merchantLogoUrl: merchantLogoUrl ?? this.merchantLogoUrl,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      type: type ?? this.type,
      source: source ?? this.source,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      accountId: accountId ?? this.accountId,
      transferToAccountId: transferToAccountId ?? this.transferToAccountId,
      isRecurring: isRecurring ?? this.isRecurring,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      importSource: importSource ?? this.importSource,
      accountLast4: accountLast4 ?? this.accountLast4,
      accountType: accountType ?? this.accountType,
      autoTags: autoTags ?? this.autoTags,
      isEmi: isEmi ?? this.isEmi,
      emiMonthsTotal: emiMonthsTotal ?? this.emiMonthsTotal,
      emiMonthsRemaining: emiMonthsRemaining ?? this.emiMonthsRemaining,
      emiMonthlyAmount: emiMonthlyAmount ?? this.emiMonthlyAmount,
    );
  }

  // WHY toMap / fromMap:
  // Hive stores data as key-value pairs. It can't store a Dart object directly.
  // toMap() converts the entity into a Map<String, dynamic> that Hive can save.
  // fromMap() reconstructs the entity from that map when reading from Hive.
  //
  // Enums are stored as their string name (e.g. ImportSource.email → 'email')
  // so stored data remains readable and doesn't break if enum order changes.

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'currencyCode': currencyCode.name,
      'convertedAmount': convertedAmount,
      'merchant': merchant,
      'merchantLogoUrl': merchantLogoUrl,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'subcategory': subcategory,
      'type': type.name,
      'source': source,
      'status': status.name,
      'referenceNumber': referenceNumber,
      'note': note,
      'tags': tags,
      'accountId': accountId,
      'transferToAccountId': transferToAccountId,
      'isRecurring': isRecurring,
      'balanceAfter': balanceAfter,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // New fields
      'importSource': importSource.name,
      'accountLast4': accountLast4,
      'accountType': accountType.name,
      'autoTags': autoTags,
      'isEmi': isEmi,
      'emiMonthsTotal': emiMonthsTotal,
      'emiMonthsRemaining': emiMonthsRemaining,
      'emiMonthlyAmount': emiMonthlyAmount,
    };
  }

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'],
      amount: map['amount'],
      currencyCode: CurrencyCode.values.firstWhere(
        (e) => e.name == map['currencyCode'],
      ),
      convertedAmount: map['convertedAmount'],
      merchant: map['merchant'],
      merchantLogoUrl: map['merchantLogoUrl'],
      timestamp: DateTime.parse(map['timestamp']),
      category: map['category'],
      subcategory: map['subcategory'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      source: map['source'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      referenceNumber: map['referenceNumber'],
      note: map['note'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      accountId: map['accountId'],
      transferToAccountId: map['transferToAccountId'],
      isRecurring: map['isRecurring'],
      balanceAfter: map['balanceAfter'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),

      // New fields — use fallback defaults when reading old cached data
      // that was stored before these fields existed.
      importSource: ImportSource.values.firstWhere(
        (e) => e.name == map['importSource'],
        orElse: () => ImportSource.unknown, // safe fallback for old Hive data
      ),
      accountLast4: map['accountLast4'],
      accountType: AccountType.values.firstWhere(
        (e) => e.name == map['accountType'],
        orElse: () => AccountType.unknown, // safe fallback
      ),
      autoTags: map['autoTags'] != null
          ? List<String>.from(map['autoTags'])
          : null,
      isEmi: map['isEmi'] ?? false, // fallback for old data
      emiMonthsTotal: map['emiMonthsTotal'],
      emiMonthsRemaining: map['emiMonthsRemaining'],
      emiMonthlyAmount: map['emiMonthlyAmount'],
    );
  }
}
