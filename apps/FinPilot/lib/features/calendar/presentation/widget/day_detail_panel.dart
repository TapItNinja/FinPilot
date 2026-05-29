// ── Day Detail Panel ──────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/calendar/presentation/providers/calendar_notifier.dart';
import 'package:mobile_app/features/calendar/presentation/widget/amount_pill.dart';
import 'package:mobile_app/features/calendar/presentation/widget/category_breakdown.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_notifier.dart';
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.isEmpty
                        ? 'No transactions'
                        : '${detail.transactions.length} transaction${detail.transactions.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
              // Summary pills
              if (!detail.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (detail.totalSpent > 0)
                      AmountPill(
                        amount: detail.totalSpent,
                        color: FinPilotTheme.expense,
                        prefix: '-',
                      ),
                    if (detail.totalIncome > 0) ...[
                      const SizedBox(height: 4),
                      AmountPill(
                        amount: detail.totalIncome,
                        color: FinPilotTheme.income,
                        prefix: '+',
                      ),
                    ],
                  ],
                ),
            ],
          ),

          if (detail.isEmpty) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No transactions on this day',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),

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
              const SizedBox(height: 16),
              const Text(
                'Spending breakdown',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
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

