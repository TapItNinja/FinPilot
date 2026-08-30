// lib/features/transactions/presentation/widgets/transaction_widget/summary_number.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_summary_notifier.dart';

class SummaryNumbers extends StatelessWidget {
  final TransactionSummary summary;

  const SummaryNumbers({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Balance Header ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL BALANCE',
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: FinPilotColors.income.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FinPilotColors.income.withValues(alpha: isDark ? 0.35 : 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_upward_rounded, color: FinPilotColors.income, size: 11),
                  SizedBox(width: 2),
                  Text(
                    '+4.2%',
                    style: TextStyle(
                      color: FinPilotColors.income,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '\$${summary.net.toStringAsFixed(2)}',
          style: TextStyle(
            color: isDark ? FinPilotColors.primaryDark : textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 12),

        // ── Income & Expense Partitioned Tiles ───────────────────────
        Row(
          children: [
            Expanded(
              child: _MetricPill(
                label: 'Income',
                amount: summary.totalIncome,
                color: FinPilotColors.income,
                icon: Icons.south_west_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricPill(
                label: 'Expenses',
                amount: summary.totalExpenses,
                color: FinPilotColors.expense,
                icon: Icons.north_east_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _MetricPill({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
