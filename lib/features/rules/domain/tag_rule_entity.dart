// WHY THIS FILE EXISTS:
// A TagRule is the user's instruction to the app:
// "Whenever you see this keyword in a merchant name, assign this category."
//
// This is a domain entity — pure Dart, no Flutter, no Hive, no external packages.
// It describes WHAT a rule is, not how it's stored or displayed.
//
// Kept separate from TransactionEntity because rules are a different
// concept — they're configuration, not financial data.
//lib/features/rules/domain/tag_rule_entity.dart
class TagRuleEntity {
  // Unique identifier for this rule.
  // We use a String ID (not int) because we'll generate it with
  // DateTime.now().millisecondsSinceEpoch.toString() — simple, unique, no package needed.
  final String id;

  // The word or phrase to look for in the merchant name.
  // e.g. 'kfc', 'swiggy', 'amazon pay'
  // We always match case-insensitively (explained in RuleEngine).
  final String keyword;

  // The category this rule assigns when it matches.
  // e.g. 'Food', 'Shopping', 'Entertainment'
  // This becomes the transaction's category if no category was already set,
  // AND is always added to autoTags regardless.
  final String category;

  // Optional: further classify within a category.
  // e.g. category='Food', subcategory='Fast Food'
  // Nullable because most rules won't need this level of detail.
  final String? subcategory;

  // When true: only match if merchant name is EXACTLY the keyword (still case-insensitive).
  // When false: match if merchant name CONTAINS the keyword anywhere.
  //
  // Example with exactMatch = false:
  //   keyword: 'amazon'
  //   matches: 'Amazon', 'Amazon Pay', 'Amazon Prime', 'amazon.in'
  //
  // Example with exactMatch = true:
  //   keyword: 'uber'
  //   matches: 'Uber', 'UBER'
  //   does NOT match: 'Uber Eats' (that would need its own rule)
  //
  // Default is false (contains match) because bank alert merchant names
  // often have extra characters (bank codes, suffixes, etc.)
  final bool exactMatch;

  // Priority determines which rule wins when multiple rules match the same merchant.
  // Higher number = higher priority.
  // e.g. if 'uber' (priority 1) and 'uber eats' (priority 2) both match 'Uber Eats',
  // the 'uber eats' rule wins because it's more specific.
  //
  // Pre-seeded rules get priority 1.
  // User-created rules get priority 2 by default, so they always override presets.
  final int priority;

  // Whether this rule is currently active.
  // Lets users disable a rule without deleting it — they can re-enable later.
  final bool isActive;

  // Whether this rule was pre-seeded by the app (true) or created by the user (false).
  // We use this in the UI to show a different label ('Built-in' vs 'Custom')
  // and to prevent accidental deletion of pre-seeded rules.
  final bool isPreset;

  // Audit timestamps — when was this rule created and last modified.
  // Useful for debugging and for sorting rules in the UI.
  final DateTime createdAt;
  final DateTime updatedAt;

  const TagRuleEntity({
    required this.id,
    required this.keyword,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.subcategory,
    this.exactMatch = false,
    this.priority = 1,
    this.isActive = true,
    this.isPreset = false,
  });

  // copyWith — same reason as TransactionEntity.
  // RuleEngine and the rules management UI will need to create modified copies.
  // e.g. to toggle isActive: rule.copyWith(isActive: false)
  TagRuleEntity copyWith({
    String? id,
    String? keyword,
    String? category,
    String? subcategory,
    bool? exactMatch,
    int? priority,
    bool? isActive,
    bool? isPreset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TagRuleEntity(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      exactMatch: exactMatch ?? this.exactMatch,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // toMap / fromMap for Hive storage — same pattern as TransactionEntity.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keyword': keyword,
      'category': category,
      'subcategory': subcategory,
      'exactMatch': exactMatch,
      'priority': priority,
      'isActive': isActive,
      'isPreset': isPreset,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TagRuleEntity.fromMap(Map<String, dynamic> map) {
    return TagRuleEntity(
      id: map['id'],
      keyword: map['keyword'],
      category: map['category'],
      subcategory: map['subcategory'],
      exactMatch: map['exactMatch'] ?? false,
      priority: map['priority'] ?? 1,
      isActive: map['isActive'] ?? true,
      isPreset: map['isPreset'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Pre-seeded rules for common Indian merchants.
  // Called once during first app launch to populate the rules box in Hive.
  // Covers the most common spending categories for Indian users.
  //
  // WHY static: these don't belong to any specific instance of TagRuleEntity.
  // They're a factory/utility — call TagRuleEntity.presets() to get the list.
  static List<TagRuleEntity> presets() {
    final now = DateTime.now();

    // Helper to make preset rules less verbose
    TagRuleEntity preset(
      String id,
      String keyword,
      String category, {
      String? subcategory,
      bool exactMatch = false,
    }) {
      return TagRuleEntity(
        id: 'preset_$id',
        keyword: keyword,
        category: category,
        subcategory: subcategory,
        exactMatch: exactMatch,
        priority: 1,
        isActive: true,
        isPreset: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    return [
      // Food & Dining
      preset('1', 'swiggy', 'Food', subcategory: 'Food Delivery'),
      preset('2', 'zomato', 'Food', subcategory: 'Food Delivery'),
      preset('3', 'kfc', 'Food', subcategory: 'Fast Food'),
      preset('4', 'mcdonalds', 'Food', subcategory: 'Fast Food'),
      preset('5', 'mcd', 'Food', subcategory: 'Fast Food'),
      preset('6', 'dominos', 'Food', subcategory: 'Fast Food'),
      preset('7', 'pizza hut', 'Food', subcategory: 'Fast Food'),
      preset('8', 'subway', 'Food', subcategory: 'Fast Food'),
      preset('9', 'starbucks', 'Food', subcategory: 'Cafe'),
      preset('10', 'cafe coffee day', 'Food', subcategory: 'Cafe'),
      preset('11', 'ccd', 'Food', subcategory: 'Cafe'),
      preset('12', 'blinkit', 'Food', subcategory: 'Groceries'),
      preset('13', 'zepto', 'Food', subcategory: 'Groceries'),
      preset('14', 'bigbasket', 'Food', subcategory: 'Groceries'),
      preset('15', 'dunzo', 'Food', subcategory: 'Groceries'),
      preset('16', 'instamart', 'Food', subcategory: 'Groceries'),

      // Shopping
      preset('17', 'amazon', 'Shopping', subcategory: 'Online'),
      preset('18', 'flipkart', 'Shopping', subcategory: 'Online'),
      preset('19', 'myntra', 'Shopping', subcategory: 'Clothing'),
      preset('20', 'ajio', 'Shopping', subcategory: 'Clothing'),
      preset('21', 'nykaa', 'Shopping', subcategory: 'Beauty'),
      preset('22', 'meesho', 'Shopping', subcategory: 'Online'),
      preset('23', 'reliance', 'Shopping', subcategory: 'Retail'),
      preset('24', 'dmart', 'Shopping', subcategory: 'Retail'),

      // Transport
      preset('25', 'uber', 'Transport', subcategory: 'Cab'),
      preset('26', 'ola', 'Transport', subcategory: 'Cab'),
      preset('27', 'rapido', 'Transport', subcategory: 'Bike Taxi'),
      preset('28', 'irctc', 'Transport', subcategory: 'Train'),
      preset('29', 'indigo', 'Transport', subcategory: 'Flight'),
      preset('30', 'air india', 'Transport', subcategory: 'Flight'),
      preset('31', 'spicejet', 'Transport', subcategory: 'Flight'),
      preset('32', 'makemytrip', 'Transport', subcategory: 'Travel'),
      preset('33', 'goibibo', 'Transport', subcategory: 'Travel'),
      preset('34', 'redbus', 'Transport', subcategory: 'Bus'),
      preset('35', 'fastag', 'Transport', subcategory: 'Toll'),

      // Entertainment
      preset('36', 'netflix', 'Entertainment', subcategory: 'Streaming'),
      preset('37', 'spotify', 'Entertainment', subcategory: 'Music'),
      preset('38', 'hotstar', 'Entertainment', subcategory: 'Streaming'),
      preset('39', 'disney', 'Entertainment', subcategory: 'Streaming'),
      preset('40', 'prime video', 'Entertainment', subcategory: 'Streaming'),
      preset('41', 'youtube', 'Entertainment', subcategory: 'Streaming'),
      preset('42', 'bookmyshow', 'Entertainment', subcategory: 'Movies'),
      preset('43', 'pvr', 'Entertainment', subcategory: 'Movies'),
      preset('44', 'inox', 'Entertainment', subcategory: 'Movies'),
      preset('45', 'apple music', 'Entertainment', subcategory: 'Music'),

      // Utilities & Bills
      preset('46', 'bescom', 'Utilities', subcategory: 'Electricity'),
      preset('47', 'bwssb', 'Utilities', subcategory: 'Water'),
      preset('48', 'airtel', 'Utilities', subcategory: 'Mobile/Internet'),
      preset('49', 'jio', 'Utilities', subcategory: 'Mobile/Internet'),
      preset('50', 'bsnl', 'Utilities', subcategory: 'Mobile/Internet'),
      preset('51', 'vi ', 'Utilities', subcategory: 'Mobile/Internet'),
      preset('52', 'tata sky', 'Utilities', subcategory: 'DTH'),
      preset('53', 'dish tv', 'Utilities', subcategory: 'DTH'),

      // Health
      preset('54', 'apollo', 'Health', subcategory: 'Pharmacy'),
      preset('55', 'medplus', 'Health', subcategory: 'Pharmacy'),
      preset('56', 'netmeds', 'Health', subcategory: 'Pharmacy'),
      preset('57', 'pharmeasy', 'Health', subcategory: 'Pharmacy'),
      preset('58', 'cult.fit', 'Health', subcategory: 'Fitness'),
      preset('59', 'cure.fit', 'Health', subcategory: 'Fitness'),

      // Finance
      preset('60', 'zerodha', 'Finance', subcategory: 'Investment'),
      preset('61', 'groww', 'Finance', subcategory: 'Investment'),
      preset('62', 'upstox', 'Finance', subcategory: 'Investment'),
      preset('63', 'coin', 'Finance', subcategory: 'Investment'),
      preset('64', 'paytm', 'Finance', subcategory: 'Wallet'),
      preset('65', 'phonepe', 'Finance', subcategory: 'Wallet'),
      preset('66', 'gpay', 'Finance', subcategory: 'Wallet'),
      preset('67', 'cred', 'Finance', subcategory: 'Credit Card'),

      // Education
      preset('68', 'udemy', 'Education', subcategory: 'Online Course'),
      preset('69', 'coursera', 'Education', subcategory: 'Online Course'),
      preset('70', 'byju', 'Education', subcategory: 'EdTech'),
      preset('71', 'unacademy', 'Education', subcategory: 'EdTech'),
    ];
  }
}
