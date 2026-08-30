// lib/features/calendar/presentation/widget/day_detail_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/calendar/presentation/providers/calendar_notifier.dart';
import 'package:mobile_app/features/calendar/presentation/widget/amount_pill.dart';
import 'package:mobile_app/features/calendar/presentation/widget/category_breakdown.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_notifier.dart';
import 'package:mobile_app/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/transaction_card.dart';

class DayDetailPanel extends ConsumerWidget {
  final DayDetail detail;
  final WidgetRef ref;

  const DayDetailPanel({super.key, required this.detail, required this.ref});

  static const _dayNames = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _monthNames = [
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = detail.date;
    final dayName = _dayNames[date.weekday];
    final monthName = _monthNames[date.month];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final onPrimary = isDark ? FinPilotColors.onPrimaryDark : Colors.white;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dayName, ${date.day} $monthName',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail.isEmpty
                        ? 'No recorded transactions'
                        : '${detail.transactions.length} transaction${detail.transactions.length == 1 ? '' : 's'}',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  // Quick Add for this day
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(initialDate: date),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, size: 18, color: onPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Summary pills
                  if (!detail.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (detail.totalSpent > 0)
                          AmountPill(
                            amount: detail.totalSpent,
                            color: FinPilotColors.expense,
                            prefix: '-',
                          ),
                        if (detail.totalIncome > 0) ...[
                          const SizedBox(height: 4),
                          AmountPill(
                            amount: detail.totalIncome,
                            color: FinPilotColors.income,
                            prefix: '+',
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          ),

          if (detail.isEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 36,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No transactions on this day',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),

            // Transaction list
            ...detail.transactions.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionCard(
                  transaction: t,
                  onDelete: () {
                    ref
                        .read(transactionNotifierProvider.notifier)
                        .deleteTransaction(t.id);
                  },
                ),
              ),
            ),

            // Category breakdown
            if (detail.categoryBreakdown.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Spending breakdown',
                style: TextStyle(
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              CategoryBreakdown(
                breakdown: detail.categoryBreakdown,
                totalSpent: detail.totalSpent,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
