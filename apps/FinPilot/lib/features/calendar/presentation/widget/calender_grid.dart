// lib/features/calendar/presentation/widget/calender_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/calendar/presentation/providers/calendar_notifier.dart';

class CalendarGrid extends ConsumerWidget {
  final CalendarState calendarState;
  const CalendarGrid({super.key, required this.calendarState});

  static const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTotals = ref.watch(dailyTotalsProvider);
    final monthlySummary = ref.watch(monthlySummaryProvider);
    final recurringDays = ref.watch(recurringDaysProvider);
    final viewingMonth = calendarState.viewingMonth;
    final selectedDate = calendarState.selectedDate;
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final onPrimary = isDark ? FinPilotColors.onPrimaryDark : Colors.white;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    final firstDay = DateTime(viewingMonth.year, viewingMonth.month, 1);
    final daysInMonth = DateTime(
      viewingMonth.year,
      viewingMonth.month + 1,
      0,
    ).day;

    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final maxSpend = dailyTotals.values.isEmpty
        ? 1.0
        : dailyTotals.values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          // ── Month Navigator Header ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(calendarProvider.notifier).goToPreviousMonth();
                },
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  size: 24,
                ),
              ),
              Text(
                '${_monthNames[viewingMonth.month]} ${viewingMonth.year}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(calendarProvider.notifier).goToNextMonth();
                },
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Month Cashflow Summary Pill ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryPillItem(
                  label: 'Inflow',
                  amount: monthlySummary.totalIncome,
                  color: FinPilotColors.income,
                ),
                Container(width: 1, height: 16, color: borderColor),
                _SummaryPillItem(
                  label: 'Outflow',
                  amount: monthlySummary.totalExpenses,
                  color: FinPilotColors.expense,
                ),
                Container(width: 1, height: 16, color: borderColor),
                _SummaryPillItem(
                  label: 'Net',
                  amount: monthlySummary.netCashflow,
                  color: monthlySummary.netCashflow >= 0 ? FinPilotColors.income : FinPilotColors.expense,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Weekday Labels Header ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays.map((d) {
              return SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // ── Calendar Month Grid ───────────────────────────────────
          ...List.generate(rows, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (colIndex) {
                  final cellIndex = rowIndex * 7 + colIndex;
                  final dayNumber = cellIndex - startOffset + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 36, height: 42);
                  }

                  final cellDate = DateTime(
                    viewingMonth.year,
                    viewingMonth.month,
                    dayNumber,
                  );
                  final isToday = cellDate.year == now.year &&
                      cellDate.month == now.month &&
                      cellDate.day == now.day;
                  final isSelected = selectedDate != null &&
                      cellDate.year == selectedDate.year &&
                      cellDate.month == selectedDate.month &&
                      cellDate.day == selectedDate.day;

                  final spend = dailyTotals[cellDate] ?? 0.0;
                  final hasSpend = spend > 0;
                  final spendFraction = maxSpend > 0 ? (spend / maxSpend).clamp(0.0, 1.0) : 0.0;
                  final hasRecurring = recurringDays.contains(dayNumber);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(calendarProvider.notifier).selectDate(cellDate);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : (hasSpend
                                ? FinPilotColors.expense.withValues(
                                    alpha: (0.08 + spendFraction * 0.18).clamp(0.08, 0.26),
                                  )
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : (isToday
                                  ? primaryColor.withValues(alpha: isDark ? 0.6 : 0.8)
                                  : (hasSpend
                                      ? FinPilotColors.expense.withValues(
                                          alpha: (0.15 + spendFraction * 0.35).clamp(0.15, 0.5),
                                        )
                                      : Colors.transparent)),
                          width: isToday ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? onPrimary
                                  : (isToday
                                      ? primaryColor
                                      : textPrimary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Dot indicator for spending & recurring bills
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (hasSpend)
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? onPrimary
                                        : FinPilotColors.expense,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (hasRecurring) ...[
                                if (hasSpend) const SizedBox(width: 2),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? onPrimary
                                        : FinPilotColors.chartPurple,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryPillItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryPillItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '\$${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
