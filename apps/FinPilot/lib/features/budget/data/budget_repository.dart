// lib/features/budget/data/budget_repository.dart
import '../domain/budget_entity.dart';
import 'budget_local_datasource.dart';

class BudgetRepository {
  final BudgetLocalDataSource dataSource;
  BudgetRepository(this.dataSource);

  Future<List<BudgetEntity>> getBudgetsForMonth(int month, int year) =>
      dataSource.getBudgetsForMonth(month, year);

  Future<BudgetEntity?> getOverallBudget(int month, int year) =>
      dataSource.getBudget('overall_${year}_$month');

  Future<BudgetEntity?> getCategoryBudget(
    String category,
    int month,
    int year,
  ) => dataSource.getBudget('${category}_${year}_$month');

  Future<void> setOverallBudget(double amount, int month, int year) =>
      dataSource.saveBudget(
        BudgetEntity.overall(limitAmount: amount, month: month, year: year),
      );

  Future<void> setCategoryBudget(
    String category,
    double amount,
    int month,
    int year,
  ) => dataSource.saveBudget(
    BudgetEntity.forCategory(
      category: category,
      limitAmount: amount,
      month: month,
      year: year,
    ),
  );

  Future<void> deleteBudget(String key) => dataSource.deleteBudget(key);
}
