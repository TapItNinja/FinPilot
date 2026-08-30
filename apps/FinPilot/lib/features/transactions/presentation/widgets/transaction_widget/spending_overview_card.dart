// lib/features/transactions/presentation/widgets/transaction_widget/spending_overview_card.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_summary_notifier.dart';

class SpendingOverviewCard extends StatelessWidget {
  final TransactionSummary summary;

  const SpendingOverviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;

    final hasSpending = summary.totalExpenses > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: (hasSpending ? FinPilotColors.chartOrange : textMuted).withValues(alpha: isDark ? 0.2 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.donut_large_rounded,
                      size: 14,
                      color: hasSpending ? FinPilotColors.chartOrange : textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Spending Overview',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                hasSpending
                    ? '\$${summary.totalExpenses.toStringAsFixed(0)} spent'
                    : 'All clear',
                style: TextStyle(
                  color: hasSpending ? textPrimary : FinPilotColors.income,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-segment progress bar or placeholder state
          if (hasSpending) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: 45,
                      child: Container(color: FinPilotColors.chartOrange),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: 30,
                      child: Container(color: FinPilotColors.chartBlue),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: 25,
                      child: Container(color: FinPilotColors.chartPurple),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniLegend(label: 'Essentials', color: FinPilotColors.chartOrange, isDark: isDark),
                _MiniLegend(label: 'Lifestyle', color: FinPilotColors.chartBlue, isDark: isDark),
                _MiniLegend(label: 'Others', color: FinPilotColors.chartPurple, isDark: isDark),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: FinPilotColors.income.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: FinPilotColors.income,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No expenses recorded in this cycle. Tap + to add.',
                    style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniLegend extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _MiniLegend({required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
