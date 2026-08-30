// lib/features/budget/presentation/providers/budget_notifier.dart
//
// Holds all budgets for the current month and computes BudgetStatus
// (spent vs limit) for each one by watching the transaction list.
//
// The Statistics screen reads budgetStatusProvider to replace the
// hardcoded ₹20,000 placeholder.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/budget_entity.dart';
import '../../data/budget_local_datasource.dart';
import '../../data/budget_repository.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';
import '../../../../features/transactions/presentation/providers/transaction_notifier.dart';
import '../../../../features/accounts/presentation/providers/account_notifier.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────
final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>(
  (ref) => BudgetLocalDataSource(),
);

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.read(budgetLocalDataSourceProvider));
});

// ── Budget notifier ───────────────────────────────────────────────────────────
// Holds all budgets for current month. Reloads when invalidated.
final budgetNotifierProvider =
    AsyncNotifierProvider<BudgetNotifier, List<BudgetEntity>>(
      BudgetNotifier.new,
    );

class BudgetNotifier extends AsyncNotifier<List<BudgetEntity>> {
  @override
  Future<List<BudgetEntity>> build() async {
    final now = DateTime.now();
    return ref
        .read(budgetRepositoryProvider)
        .getBudgetsForMonth(now.month, now.year);
  }

  Future<void> setOverallBudget(double amount) async {
    final now = DateTime.now();
    await ref
        .read(budgetRepositoryProvider)
        .setOverallBudget(amount, now.month, now.year);
    await _reload();
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    final now = DateTime.now();
    await ref
        .read(budgetRepositoryProvider)
        .setCategoryBudget(category, amount, now.month, now.year);
    await _reload();
  }

  Future<void> deleteBudget(String key) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(key);
    await _reload();
  }

  Future<void> _reload() async {
    final now = DateTime.now();
    state = AsyncData(
      await ref
          .read(budgetRepositoryProvider)
          .getBudgetsForMonth(now.month, now.year),
    );
  }
}

// ── Budget status provider ────────────────────────────────────────────────────
// Computes how much has been spent against each budget.
// Watches transactions + selected account + unfrozen accounts so it stays in sync.
final budgetStatusProvider = Provider<List<BudgetStatus>>((ref) {
  final budgetState = ref.watch(budgetNotifierProvider);
  final transactionState = ref.watch(transactionNotifierProvider);
  final selectedAccount = ref.watch(selectedAccountProvider);
  final unfrozenIds = ref.watch(unfrozenAccountIdsProvider);

  final budgets = budgetState.asData?.value ?? [];
  final transactions = transactionState.asData?.value ?? [];

  if (budgets.isEmpty) {
    return [];
  }

  // Filter transactions to current month
  final now = DateTime.now();
  final monthlyDebits = transactions.where((t) {
    final inMonth =
        t.timestamp.year == now.year && t.timestamp.month == now.month;
    final inAccount = selectedAccount != null
        ? (!selectedAccount.isFrozen && t.accountId == selectedAccount.id)
        : unfrozenIds.contains(t.accountId);
    return inMonth && inAccount && t.type == TransactionType.debit;
  }).toList();

  final totalSpent = monthlyDebits.fold(0.0, (sum, t) => sum + t.amount);

  // Category spending map
  final categorySpend = <String, double>{};
  for (final t in monthlyDebits) {
    categorySpend[t.category] = (categorySpend[t.category] ?? 0) + t.amount;
  }

  return budgets.map((budget) {
    final spent = budget.isOverall
        ? totalSpent
        : (categorySpend[budget.category] ?? 0);
    return BudgetStatus(budget: budget, spent: spent);
  }).toList();
});

// Convenience: just the overall budget status
final overallBudgetStatusProvider = Provider<BudgetStatus?>((ref) {
  final statuses = ref.watch(budgetStatusProvider);
  try {
    return statuses.firstWhere((s) => s.budget.isOverall);
  } catch (_) {
    return null;
  }
});
