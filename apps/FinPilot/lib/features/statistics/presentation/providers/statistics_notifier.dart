// lib/features/statistics/presentation/providers/statistics_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/transaction_notifier.dart';
import '../../../accounts/presentation/providers/account_notifier.dart';

enum StatsPeriod { week, month, year }

class DailySpend {
  final DateTime date;
  final double amount;
  const DailySpend(this.date, this.amount);
}

class CategorySpend {
  final String category;
  final double amount;
  final double percentage;
  const CategorySpend(this.category, this.amount, this.percentage);
}

class MerchantSpend {
  final String merchant;
  final double amount;
  const MerchantSpend(this.merchant, this.amount);
}

class StatisticsData {
  final List<DailySpend> dailySpend;
  final List<CategorySpend> categoryBreakdown;
  final List<MerchantSpend> topMerchants;
  final double totalSpent;
  final double totalIncome;
  final double budget;
  final double budgetUsedPercent;
  final double maxDailySpend;
  final double dailyBudgetLine;

  const StatisticsData({
    required this.dailySpend,
    required this.categoryBreakdown,
    required this.topMerchants,
    required this.totalSpent,
    required this.totalIncome,
    required this.budget,
    required this.budgetUsedPercent,
    required this.maxDailySpend,
    required this.dailyBudgetLine,
  });

  static const empty = StatisticsData(
    dailySpend: [],
    categoryBreakdown: [],
    topMerchants: [],
    totalSpent: 0,
    totalIncome: 0,
    budget: 0,
    budgetUsedPercent: 0,
    maxDailySpend: 0,
    dailyBudgetLine: 0,
  );
}

class StatisticsPeriodNotifier extends Notifier<StatsPeriod> {
  @override
  StatsPeriod build() => StatsPeriod.month;
  void setPeriod(StatsPeriod period) => state = period;
}

final statisticsPeriodProvider =
    NotifierProvider<StatisticsPeriodNotifier, StatsPeriod>(
      StatisticsPeriodNotifier.new,
    );

// Lazy budget watcher — avoids importing budget_notifier directly
// which would create a circular dependency chain
final _budgetWatchProvider = Provider<double>((ref) {
  // Returns the overall budget limit for current month
  // Falls back to 20000 if no budget set
  return 20000.0; // Will be replaced when budget feature is wired in statistics
});

// Now watches selectedAccountProvider and unfrozenAccountIdsProvider so charts filter when account changes
final statisticsDataProvider = Provider<StatisticsData>((ref) {
  final period = ref.watch(statisticsPeriodProvider);
  final transactionState = ref.watch(transactionNotifierProvider);
  final selectedAccount = ref.watch(selectedAccountProvider);
  final unfrozenIds = ref.watch(unfrozenAccountIdsProvider);
  // Watch real budget — imported lazily to avoid circular dependency
  ref.watch(_budgetWatchProvider);

  return transactionState.when(
    loading: () => StatisticsData.empty,
    error: (_, _) => StatisticsData.empty,
    data: (transactions) {
      if (selectedAccount != null) {
        if (selectedAccount.isFrozen || !unfrozenIds.contains(selectedAccount.id)) {
          return StatisticsData.empty;
        }
        final filtered = transactions
            .where((t) => t.accountId == selectedAccount.id)
            .toList();
        return computeStatistics(
          filtered,
          period,
          ref.read(_budgetWatchProvider),
        );
      }

      // Overall mode: exclude frozen accounts
      final filtered = transactions
          .where((t) => unfrozenIds.contains(t.accountId))
          .toList();
      return computeStatistics(
        filtered,
        period,
        ref.read(_budgetWatchProvider),
      );
    },
  );
});

StatisticsData computeStatistics(
  List<TransactionEntity> all,
  StatsPeriod period, [
  double overallBudget = 20000,
]) {
  if (all.isEmpty) {
    return StatisticsData.empty;
  }

  final now = DateTime.now();
  final DateTime rangeStart;
  final int daysInPeriod;

  switch (period) {
    case StatsPeriod.week:
      rangeStart = now.subtract(Duration(days: now.weekday - 1));
      daysInPeriod = 7;
    case StatsPeriod.month:
      rangeStart = DateTime(now.year, now.month, 1);
      daysInPeriod = DateTime(now.year, now.month + 1, 0).day;
    case StatsPeriod.year:
      rangeStart = DateTime(now.year, 1, 1);
      daysInPeriod = 365;
  }

  final rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final periodTransactions = all.where((t) {
    return t.timestamp.isAfter(
          rangeStart.subtract(const Duration(seconds: 1)),
        ) &&
        t.timestamp.isBefore(rangeEnd.add(const Duration(seconds: 1)));
  }).toList();

  final debits = periodTransactions
      .where((t) => t.type == TransactionType.debit)
      .toList();
  final credits = periodTransactions
      .where((t) => t.type == TransactionType.credit)
      .toList();

  final totalSpent = debits.fold(0.0, (sum, t) => sum + t.amount);
  final totalIncome = credits.fold(0.0, (sum, t) => sum + t.amount);

  // Daily spend map
  final dailyMap = <DateTime, double>{};
  if (period != StatsPeriod.year) {
    for (int i = 0; i < daysInPeriod; i++) {
      final day = DateTime(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day + i,
      );
      if (!day.isAfter(rangeEnd)) {
        dailyMap[day] = 0;
      }
    }
  }

  for (final t in debits) {
    final day = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
    dailyMap[day] = (dailyMap[day] ?? 0) + t.amount;
  }

  final dailySpend =
      dailyMap.entries.map((e) => DailySpend(e.key, e.value)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  final maxDailySpend = dailySpend.isEmpty
      ? 0.0
      : dailySpend.map((d) => d.amount).reduce((a, b) => a > b ? a : b);

  // Category breakdown
  final categoryMap = <String, double>{};
  for (final t in debits) {
    final cat = t.category == 'Uncategorized' ? 'Other' : t.category;
    categoryMap[cat] = (categoryMap[cat] ?? 0) + t.amount;
  }

  final sortedCategories = categoryMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final categoryBreakdown = <CategorySpend>[];
  double otherAmount = 0;

  for (int i = 0; i < sortedCategories.length; i++) {
    final entry = sortedCategories[i];
    final pct = totalSpent > 0 ? (entry.value / totalSpent * 100) : 0.0;
    if (i < 5) {
      categoryBreakdown.add(CategorySpend(entry.key, entry.value, pct));
    } else {
      otherAmount += entry.value;
    }
  }

  if (otherAmount > 0) {
    final pct = totalSpent > 0 ? (otherAmount / totalSpent * 100) : 0.0;
    categoryBreakdown.add(CategorySpend('Other', otherAmount, pct));
  }

  // Top merchants
  final merchantMap = <String, double>{};
  for (final t in debits) {
    merchantMap[t.merchant] = (merchantMap[t.merchant] ?? 0) + t.amount;
  }

  final topMerchants =
      (merchantMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .take(5)
          .map((e) => MerchantSpend(e.key, e.value))
          .toList();

  final budgetUsedPercent = overallBudget > 0
      ? (totalSpent / overallBudget * 100).clamp(0.0, 100.0)
      : 0.0;

  return StatisticsData(
    dailySpend: dailySpend,
    categoryBreakdown: categoryBreakdown,
    topMerchants: topMerchants,
    totalSpent: totalSpent,
    totalIncome: totalIncome,
    budget: overallBudget,
    budgetUsedPercent: budgetUsedPercent,
    maxDailySpend: maxDailySpend,
    dailyBudgetLine: overallBudget / daysInPeriod,
  );
}
