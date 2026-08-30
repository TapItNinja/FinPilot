// lib/features/accounts/domain/entities/account_entity.dart
//
// WHY THIS FILE EXISTS:
// AccountEntity represents one bank account or credit card the user has added.
// Every transaction belongs to one account via accountId.
// The card gradient, last 4 digits, and type are stored here.
//lib/features/accounts/domain/entities/account_entity.dart
enum AccountKind { bank, creditCard }

// Preset gradient themes for the card — matches the picker in add_account_flow
enum CardGradientTheme {
  indigoPurple,
  orangeRed,
  tealBlue,
  pinkLavender,
  darkSlate,
  pinkCoral,
  peachCream,
  mintGreen,
  crimsonRed,
  midnightBlue,
}

class AccountEntity {
  final String id;
  final String name; // e.g. "SBI Savings", "Axis ACE"
  final AccountKind kind; // bank or credit card
  final String last4Digits; // last 4 digits of account/card number
  final CardGradientTheme gradientTheme;
  final bool isActive;
  final bool isFrozen; // Whether the card is physically frozen
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.kind,
    required this.last4Digits,
    required this.gradientTheme,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isFrozen = false,
  });

  AccountEntity copyWith({
    String? name,
    AccountKind? kind,
    String? last4Digits,
    CardGradientTheme? gradientTheme,
    bool? isActive,
    bool? isFrozen,
    DateTime? updatedAt,
  }) {
    return AccountEntity(
      id: id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      last4Digits: last4Digits ?? this.last4Digits,
      gradientTheme: gradientTheme ?? this.gradientTheme,
      isActive: isActive ?? this.isActive,
      isFrozen: isFrozen ?? this.isFrozen,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'last4Digits': last4Digits,
    'gradientTheme': gradientTheme.name,
    'isActive': isActive,
    'isFrozen': isFrozen,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AccountEntity.fromMap(Map<String, dynamic> map) => AccountEntity(
    id: map['id'],
    name: map['name'],
    kind: AccountKind.values.firstWhere(
      (e) => e.name == map['kind'],
      orElse: () => AccountKind.bank,
    ),
    last4Digits: map['last4Digits'] ?? '0000',
    gradientTheme: CardGradientTheme.values.firstWhere(
      (e) => e.name == map['gradientTheme'],
      orElse: () => CardGradientTheme.indigoPurple,
    ),
    isActive: map['isActive'] ?? true,
    isFrozen: map['isFrozen'] ?? false,
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );
}
