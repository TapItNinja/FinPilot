// lib/features/transactions/presentation/widgets/transaction_widget/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/category_styles.dart';
import '../../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onDelete;

  const TransactionCard({super.key, required this.transaction, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final style = getCategoryStyle(transaction.category);
    final isCredit = transaction.type == TransactionType.credit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountColor = isCredit ? FinPilotColors.income : FinPilotColors.expense;
    final amountPrefix = isCredit ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: FinPilotColors.expense.withValues(alpha: isDark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          border: Border.all(
            color: FinPilotColors.expense.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: FinPilotColors.expense,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: FinPilotColors.expense,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          border: Border.all(
            color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // ── Category Icon ──────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 20),
            ),

            const SizedBox(width: 12),

            // ── Merchant + Category ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    style: TextStyle(
                      color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: TextStyle(
                          color: style.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (transaction.isEmi) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: FinPilotColors.warning.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EMI',
                            style: TextStyle(
                              color: FinPilotColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Amount + Status ────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(status: transaction.status, isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case TransactionStatus.completed:
        return const SizedBox.shrink();
      case TransactionStatus.pending:
        color = FinPilotColors.warning;
        label = 'Pending';
      case TransactionStatus.failed:
        color = FinPilotColors.expense;
        label = 'Failed';
      case TransactionStatus.cancelled:
        color = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;
        label = 'Cancelled';
      case TransactionStatus.reversed:
        color = FinPilotColors.income;
        label = 'Reversed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
