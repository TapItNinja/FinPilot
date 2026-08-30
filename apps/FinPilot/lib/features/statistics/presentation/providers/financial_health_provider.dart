// lib/features/statistics/presentation/providers/financial_health_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/budget/presentation/providers/budget_notifier.dart';
import 'package:mobile_app/features/statistics/domain/financial_health_calculator.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_notifier.dart';

final financialHealthProvider = Provider<FinancialHealthResult>((ref) {
  final transactions = ref.watch(transactionNotifierProvider).asData?.value ?? [];
  final unfrozenIds = ref.watch(unfrozenAccountIdsProvider);
  final budgets = ref.watch(budgetStatusProvider);

  // Filter transactions of active (unfrozen) accounts
  final activeTransactions = transactions
      .where((t) => unfrozenIds.contains(t.accountId))
      .toList();

  return FinancialHealthCalculator.calculate(
    transactions: activeTransactions,
    budgets: budgets,
  );
});
