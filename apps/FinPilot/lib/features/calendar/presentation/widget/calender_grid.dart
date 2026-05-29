// ── Calendar Grid ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
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
    final viewingMonth = calendarState.viewingMonth;
    final selectedDate = calendarState.selectedDate;
    final now = DateTime.now();

    // Build calendar days
    // First day of month (1 = Monday, 7 = Sunday in DateTime.weekday)
    final firstDay = DateTime(viewingMonth.year, viewingMonth.month, 1);
    final daysInMonth = DateTime(
      viewingMonth.year,
      viewingMonth.month + 1,
      0,
    ).day;

    // Offset: how many empty cells before day 1
    // DateTime.weekday: 1=Mon, 7=Sun. We want Mon=0 offset.
    final startOffset = firstDay.weekday - 1;

    // Total cells = offset + days in month, rounded up to full weeks
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    // Max daily spend in this month for dot intensity scaling
    final maxSpend = dailyTotals.values.isEmpty
        ? 1.0
        : dailyTotals.values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FinPilotTheme.darkBorder),
      ),
      child: Column(
        children: [
          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(calendarProvider.notifier).goToPreviousMonth(),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white70,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '${_monthNames[viewingMonth.month]} ${viewingMonth.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(calendarProvider.notifier).goToNextMonth(),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: _isCurrentMonth(viewingMonth, now)
                      ? Colors.white24
                      : Colors.white70,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weekday headers
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          ...List.generate(rows, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final dayNumber = cellIndex - startOffset + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }

                  final date = DateTime(
                    viewingMonth.year,
                    viewingMonth.month,
                    dayNumber,
                  );

                  final isToday =
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  final isSelected =
                      selectedDate != null &&
                      selectedDate.year == date.year &&
                      selectedDate.month == date.month &&
                      selectedDate.day == date.day;

                  final isFuture = date.isAfter(
                    DateTime(now.year, now.month, now.day),
                  );

                  final daySpend = dailyTotals[date];
                  final hasTransactions = daySpend != null && daySpend > 0;

                  // Dot intensity based on spend relative to max
                  final intensity = hasTransactions
                      ? (daySpend / maxSpend).clamp(0.2, 1.0)
                      : 0.0;

                  return Expanded(
                    child: GestureDetector(
                      onTap: isFuture
                          ? null
                          : () => ref
                                .read(calendarProvider.notifier)
                                .selectDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FinPilotTheme.primary
                              : isToday
                              ? FinPilotTheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: FinPilotTheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                color: isFuture
                                    ? Colors.white24
                                    : isSelected
                                    ? Colors.white
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Spend dot
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasTransactions
                                    ? (isSelected
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : FinPilotTheme.expense.withValues(
                                              alpha: intensity,
                                            ))
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
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

  bool _isCurrentMonth(DateTime viewing, DateTime now) {
    return viewing.year == now.year && viewing.month == now.month;
  }
}
