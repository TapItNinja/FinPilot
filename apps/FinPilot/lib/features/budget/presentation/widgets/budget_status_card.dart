// ── Budget Status Card ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/category_styles.dart';
import 'package:mobile_app/features/budget/domain/budget_entity.dart';

class BudgetStatusCard extends StatelessWidget {
  final BudgetStatus status;
  final VoidCallback onEdit;

  const BudgetStatusCard({super.key, required this.status, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final budget = status.budget;
    final color = _healthColor(status.health);
    final style = budget.isOverall
        ? null
        : getCategoryStyle(budget.category ?? 'Uncategorized');

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status.isOverBudget
                ? FinPilotTheme.expense.withValues(alpha: 0.4)
                : FinPilotTheme.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (style != null) ...[
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(style.icon, color: style.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      budget.isOverall ? 'Overall' : budget.category!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '₹${_fmt(status.spent)} / ₹${_fmt(budget.limitAmount)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_outlined,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (status.percentUsed / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: FinPilotTheme.darkSurface2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status.isOverBudget
                      ? '₹${_fmt(status.spent - budget.limitAmount)} over budget'
                      : '₹${_fmt(status.remaining)} remaining',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${status.percentUsed.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _healthColor(BudgetHealthLevel health) {
    switch (health) {
      case BudgetHealthLevel.safe:
        return FinPilotTheme.income;
      case BudgetHealthLevel.warning:
        return FinPilotTheme.warning;
      case BudgetHealthLevel.over:
        return FinPilotTheme.expense;
    }
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
