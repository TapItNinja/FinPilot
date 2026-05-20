enum TransactionType { credit, debit, transfer, refund }

enum TransactionStatus { pending, completed, failed, cancelled, reversed }

enum CurrencyCode { usd, eur, inr, gbp }

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

  final String source;

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
  });
  //Serialization-> toMap and fromMap for converting to and from Map<String, dynamic> which is useful for storing in databases or sending over network.
  //convert object ↔ savable format

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
    );
  }
}
