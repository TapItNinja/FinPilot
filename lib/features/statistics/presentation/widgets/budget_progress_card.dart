// lib/features/statistics/presentation/widgets/budget_progress_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/budget/presentation/providers/budget_notifier.dart';
import 'package:mobile_app/features/budget/presentation/screens/budget_screen.dart';
import 'package:mobile_app/features/statistics/presentation/providers/statistics_notifier.dart';

class BudgetProgress extends ConsumerWidget {
  final StatisticsData data;

  const BudgetProgress({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatus = ref.watch(overallBudgetStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    if (overallStatus == null) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(
              color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set a Monthly Budget',
                      style: TextStyle(
                        color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track your spending against a limit',
                      style: TextStyle(
                        color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    final pct = overallStatus.percentUsed;
    final isOverBudget = overallStatus.isOverBudget;
    final barColor = pct < 70
        ? FinPilotColors.income
        : pct < 90
            ? FinPilotColors.warning
            : FinPilotColors.expense;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BudgetScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOverBudget
                ? FinPilotColors.expense.withValues(alpha: 0.4)
                : (isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isOverBudget
                          ? 'Over budget!'
                          : '${pct.toStringAsFixed(0)}% used',
                      style: TextStyle(
                        color: barColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: \$${_fmt(overallStatus.spent)}',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Budget: \$${_fmt(overallStatus.budget.limitAmount)}',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
