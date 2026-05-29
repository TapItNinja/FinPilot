// lib/features/statistics/presentation/widgets/budget_progress_card.dart
//
// UPDATED: Now reads from real budgetStatusProvider instead of hardcoded data.
// Shows overall budget progress + "Manage Budgets" button to navigate to BudgetScreen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/budget/presentation/providers/budget_notifier.dart';
import 'package:mobile_app/features/budget/presentation/screens/budget_screen.dart';
import 'package:mobile_app/features/statistics/presentation/providers/statistics_notifier.dart';

// ConsumerWidget so it can watch budgetStatusProvider directly
class BudgetProgress extends ConsumerWidget {
  final StatisticsData
  data; // kept for backward compat — we use budgetStatus instead

  const BudgetProgress({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatus = ref.watch(overallBudgetStatusProvider);

    // If no budget set yet — show a prompt to set one
    if (overallStatus == null) {
      return GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BudgetScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FinPilotTheme.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FinPilotTheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FinPilotTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: FinPilotTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set a Monthly Budget',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Track your spending against a limit',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    // Budget is set — show progress
    final pct = overallStatus.percentUsed;
    final isOverBudget = overallStatus.isOverBudget;
    final barColor = pct < 70
        ? FinPilotTheme.income
        : pct < 90
        ? FinPilotTheme.warning
        : FinPilotTheme.expense;

    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BudgetScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverBudget
                ? FinPilotTheme.expense.withValues(alpha: 0.3)
                : FinPilotTheme.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white24,
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
                minHeight: 10,
                backgroundColor: FinPilotTheme.darkSurface2,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ₹${_fmt(overallStatus.spent)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  'Budget: ₹${_fmt(overallStatus.budget.limitAmount)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),

            if (isOverBudget) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: FinPilotTheme.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: FinPilotTheme.expense,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '₹${_fmt(overallStatus.spent - overallStatus.budget.limitAmount)} over limit',
                      style: const TextStyle(
                        color: FinPilotTheme.expense,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    }
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }
}
