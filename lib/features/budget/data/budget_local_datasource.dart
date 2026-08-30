// lib/features/budget/data/budget_local_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/budget_entity.dart';

class BudgetLocalDataSource {
  static const _boxName = 'budgets_box';
  Box? _box;

  Future<Box> get _openBox async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  // Get all budgets for a specific month/year
  Future<List<BudgetEntity>> getBudgetsForMonth(int month, int year) async {
    final box = await _openBox;
    final budgets = <BudgetEntity>[];

    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        final budget = BudgetEntity.fromMap(Map<String, dynamic>.from(value));
        if (budget.month == month && budget.year == year) {
          budgets.add(budget);
        }
      }
    }

    return budgets;
  }

  // Get a specific budget by its key
  Future<BudgetEntity?> getBudget(String key) async {
    final box = await _openBox;
    final value = box.get(key);
    if (value == null) {
      return null;
    }
    return BudgetEntity.fromMap(Map<String, dynamic>.from(value));
  }

  // Save or update a budget
  Future<void> saveBudget(BudgetEntity budget) async {
    final box = await _openBox;
    await box.put(budget.key, budget.toMap());
  }

  // Delete a budget
  Future<void> deleteBudget(String key) async {
    final box = await _openBox;
    await box.delete(key);
  }
}
