// lib/features/transactions/presentation/providers/transaction_summary_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_notifier.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';

class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final double net;
  final int transactionCount;
  final String topCategory;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
    required this.transactionCount,
    required this.topCategory,
  });

  bool get isPositive => net >= 0;

  static const empty = TransactionSummary(
    totalIncome: 0,
    totalExpenses: 0,
    net: 0,
    transactionCount: 0,
    topCategory: 'None',
  );
}

// Summary filtered by selected account (null = all unfrozen accounts)
final transactionSummaryProvider = Provider<TransactionSummary>((ref) {
  final transactionState = ref.watch(transactionNotifierProvider);
  final selectedAccount = ref.watch(selectedAccountProvider);
  final unfrozenIds = ref.watch(unfrozenAccountIdsProvider);

  return transactionState.when(
    loading: () => TransactionSummary.empty,
    error: (error, stackTrace) => TransactionSummary.empty,
    data: (transactions) {
      if (selectedAccount != null) {
        if (selectedAccount.isFrozen || !unfrozenIds.contains(selectedAccount.id)) {
          return TransactionSummary.empty;
        }
        final filtered = transactions
            .where((t) => t.accountId == selectedAccount.id)
            .toList();
        return computeSummary(filtered);
      }

      // Overall mode: exclude all frozen accounts
      final filtered = transactions
          .where((t) => unfrozenIds.contains(t.accountId))
          .toList();
      return computeSummary(filtered);
    },
  );
});

TransactionSummary computeSummary(List<TransactionEntity> all) {
  if (all.isEmpty) {
    return TransactionSummary.empty;
  }

  final now = DateTime.now();
  final thisMonth = all.where((t) {
    return t.timestamp.year == now.year && t.timestamp.month == now.month;
  }).toList();

  if (thisMonth.isEmpty) {
    return TransactionSummary.empty;
  }

  double income = 0;
  double expenses = 0;
  final categoryTotals = <String, double>{};

  for (final t in thisMonth) {
    if (t.type == TransactionType.credit) {
      income += t.amount;
    } else if (t.type == TransactionType.debit) {
      expenses += t.amount;
      if (t.category != 'Income') {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }
    }
  }

  String topCategory = 'None';
  if (categoryTotals.isNotEmpty) {
    topCategory = categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  return TransactionSummary(
    totalIncome: income,
    totalExpenses: expenses,
    net: income - expenses,
    transactionCount: thisMonth.length,
    topCategory: topCategory,
  );
}

// Grouped transactions filtered by selected account (and excluding frozen accounts in overall mode)
final groupedTransactionsProvider =
    Provider<Map<String, List<TransactionEntity>>>((ref) {
      final transactionState = ref.watch(transactionNotifierProvider);
      final selectedAccount = ref.watch(selectedAccountProvider);
      final unfrozenIds = ref.watch(unfrozenAccountIdsProvider);

      return transactionState.when(
        loading: () => {},
        error: (error, stackTrace) => {},
        data: (transactions) {
          if (selectedAccount != null) {
            if (selectedAccount.isFrozen || !unfrozenIds.contains(selectedAccount.id)) {
              return {};
            }
            final filtered = transactions
                .where((t) => t.accountId == selectedAccount.id)
                .toList();
            return groupByDate(filtered);
          }

          // Overall mode: exclude transactions from frozen accounts
          final filtered = transactions
              .where((t) => unfrozenIds.contains(t.accountId))
              .toList();
          return groupByDate(filtered);
        },
      );
    });

Map<String, List<TransactionEntity>> groupByDate(
  List<TransactionEntity> transactions,
) {
  if (transactions.isEmpty) {
    return {};
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final grouped = <String, List<TransactionEntity>>{};

  final sorted = [...transactions]
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  for (final t in sorted) {
    final date = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);

    String label;
    if (date == today) {
      label = 'Today';
    } else if (date == yesterday) {
      label = 'Yesterday';
    } else {
      final day = date.day;
      final month = monthName(date.month);
      label = date.year == now.year
          ? '$day $month'
          : '$day $month ${date.year}';
    }

    grouped.putIfAbsent(label, () => []).add(t);
  }

  return grouped;
}

String monthName(int month) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[month];
}
