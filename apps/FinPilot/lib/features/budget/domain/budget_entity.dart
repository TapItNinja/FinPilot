// lib/features/budget/domain/budget_entity.dart
//
// BudgetEntity represents one budget entry.
// Can be an overall monthly budget OR a per-category budget.
// Both are stored in the same Hive box — differentiated by isOverall flag.

class BudgetEntity {
  final String id;
  final bool isOverall; // true = overall monthly budget
  final String? category; // null if isOverall = true
  final double limitAmount; // the budget cap in INR
  final int month; // 1-12
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.id,
    required this.isOverall,
    required this.limitAmount,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  // Convenience: key used to look up a budget in the box
  // Overall: "overall_2026_5"
  // Category: "Food_2026_5"
  String get key =>
      isOverall ? 'overall_${year}_$month' : '${category}_${year}_$month';

  BudgetEntity copyWith({double? limitAmount, DateTime? updatedAt}) {
    return BudgetEntity(
      id: id,
      isOverall: isOverall,
      category: category,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month,
      year: year,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'isOverall': isOverall,
    'category': category,
    'limitAmount': limitAmount,
    'month': month,
    'year': year,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory BudgetEntity.fromMap(Map<String, dynamic> map) => BudgetEntity(
    id: map['id'],
    isOverall: map['isOverall'] ?? false,
    category: map['category'],
    limitAmount: map['limitAmount']?.toDouble() ?? 0,
    month: map['month'],
    year: map['year'],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );

  // Factory helpers for creating new budgets
  factory BudgetEntity.overall({
    required double limitAmount,
    required int month,
    required int year,
  }) {
    final now = DateTime.now();
    return BudgetEntity(
      id: 'overall_${year}_$month',
      isOverall: true,
      limitAmount: limitAmount,
      month: month,
      year: year,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory BudgetEntity.forCategory({
    required String category,
    required double limitAmount,
    required int month,
    required int year,
  }) {
    final now = DateTime.now();
    return BudgetEntity(
      id: '${category}_${year}_$month',
      isOverall: false,
      category: category,
      limitAmount: limitAmount,
      month: month,
      year: year,
      createdAt: now,
      updatedAt: now,
    );
  }
}

// Computed budget status — how much spent vs limit
class BudgetStatus {
  final BudgetEntity budget;
  final double spent;

  const BudgetStatus({required this.budget, required this.spent});

  double get remaining =>
      (budget.limitAmount - spent).clamp(0, double.infinity);
  double get percentUsed => budget.limitAmount > 0
      ? (spent / budget.limitAmount * 100).clamp(0, 100)
      : 0;
  bool get isOverBudget => spent > budget.limitAmount;
  bool get isWarning => percentUsed >= 80 && !isOverBudget;
  bool get isSafe => percentUsed < 80;

  // Color indicator: green < 80%, orange 80-100%, red > 100%
  BudgetHealthLevel get health {
    if (isOverBudget) {
      return BudgetHealthLevel.over;
    }
    if (isWarning) {
      return BudgetHealthLevel.warning;
    }
    return BudgetHealthLevel.safe;
  }
}

enum BudgetHealthLevel { safe, warning, over }
