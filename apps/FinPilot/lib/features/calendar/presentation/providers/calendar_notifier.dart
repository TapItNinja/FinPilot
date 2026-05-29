// lib/features/calendar/presentation/providers/calendar_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/transaction_notifier.dart';
import '../../../accounts/presentation/providers/account_notifier.dart';

class CalendarState {
  final DateTime viewingMonth;
  final DateTime? selectedDate;

  const CalendarState({required this.viewingMonth, this.selectedDate});

  CalendarState copyWith({
    DateTime? viewingMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
  }) {
    return CalendarState(
      viewingMonth: viewingMonth ?? this.viewingMonth,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      viewingMonth: DateTime(now.year, now.month),
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  void goToPreviousMonth() {
    final current = state.viewingMonth;
    state = state.copyWith(
      viewingMonth: DateTime(current.year, current.month - 1),
      clearSelectedDate: true,
    );
  }

  void goToNextMonth() {
    final current = state.viewingMonth;
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) {
      return;
    }
    state = state.copyWith(viewingMonth: next, clearSelectedDate: true);
  }

  void selectDate(DateTime date) {
    final selected = state.selectedDate;
    if (selected != null &&
        selected.year == date.year &&
        selected.month == date.month &&
        selected.day == date.day) {
      state = state.copyWith(clearSelectedDate: true);
    } else {
      state = state.copyWith(selectedDate: date);
    }
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  CalendarNotifier.new,
);

// Now filters by selected account
final dailyTotalsProvider = Provider<Map<DateTime, double>>((ref) {
  final calendarState = ref.watch(calendarProvider);
  final transactionState = ref.watch(transactionNotifierProvider);
  final selectedAccount = ref.watch(selectedAccountProvider);

  return transactionState.when(
    loading: () => {},
    error: (error, stackTrace) => {},
    data: (transactions) {
      final month = calendarState.viewingMonth;

      // Filter by account if selected
      final filtered = selectedAccount == null
          ? transactions
          : transactions
                .where((t) => t.accountId == selectedAccount.id)
                .toList();

      final result = <DateTime, double>{};
      for (final t in filtered) {
        if (t.type != TransactionType.debit) {
          continue;
        }
        if (t.timestamp.year != month.year ||
            t.timestamp.month != month.month) {
          continue;
        }
        final day = DateTime(
          t.timestamp.year,
          t.timestamp.month,
          t.timestamp.day,
        );
        result[day] = (result[day] ?? 0) + t.amount;
      }
      return result;
    },
  );
});

class DayDetail {
  final DateTime date;
  final List<TransactionEntity> transactions;
  final double totalSpent;
  final double totalIncome;
  final Map<String, double> categoryBreakdown;

  const DayDetail({
    required this.date,
    required this.transactions,
    required this.totalSpent,
    required this.totalIncome,
    required this.categoryBreakdown,
  });

  bool get isEmpty => transactions.isEmpty;

  static DayDetail empty(DateTime date) => DayDetail(
    date: date,
    transactions: [],
    totalSpent: 0,
    totalIncome: 0,
    categoryBreakdown: {},
  );
}

// Also filters by selected account
final selectedDayDetailProvider = Provider<DayDetail?>((ref) {
  final calendarState = ref.watch(calendarProvider);
  final selectedDate = calendarState.selectedDate;
  if (selectedDate == null) {
    return null;
  }

  final transactionState = ref.watch(transactionNotifierProvider);
  final selectedAccount = ref.watch(selectedAccountProvider);

  return transactionState.when(
    loading: () => DayDetail.empty(selectedDate),
    error: (error, stackTrace) => DayDetail.empty(selectedDate),
    data: (transactions) {
      // Filter by account first, then by date
      final accountFiltered = selectedAccount == null
          ? transactions
          : transactions
                .where((t) => t.accountId == selectedAccount.id)
                .toList();

      final dayTransactions = accountFiltered.where((t) {
        return t.timestamp.year == selectedDate.year &&
            t.timestamp.month == selectedDate.month &&
            t.timestamp.day == selectedDate.day;
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      double totalSpent = 0;
      double totalIncome = 0;
      final categoryBreakdown = <String, double>{};

      for (final t in dayTransactions) {
        if (t.type == TransactionType.debit) {
          totalSpent += t.amount;
          final cat = t.category == 'Uncategorized' ? 'Other' : t.category;
          categoryBreakdown[cat] = (categoryBreakdown[cat] ?? 0) + t.amount;
        } else if (t.type == TransactionType.credit) {
          totalIncome += t.amount;
        }
      }

      return DayDetail(
        date: selectedDate,
        transactions: dayTransactions,
        totalSpent: totalSpent,
        totalIncome: totalIncome,
        categoryBreakdown: categoryBreakdown,
      );
    },
  );
});
