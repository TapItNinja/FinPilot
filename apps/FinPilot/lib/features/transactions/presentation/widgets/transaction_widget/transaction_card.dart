// WHY THIS FILE EXISTS:
// The individual transaction card shown in the list.
// Wrapped in Dismissible for swipe-to-delete.
//
// Design decisions:
// - Category icon in a colored circle on the left — instant visual scanning
// - Merchant name bold, category below in muted color
// - Amount right-aligned, color-coded (green = credit, red = debit)
// - EMI badge if transaction is an EMI
// - Subtle border, no elevation — flat cards feel more premium
//lib/features/transactions/presentation/widgets/transaction_card.dart
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
    final amountColor = isCredit ? FinPilotTheme.income : FinPilotTheme.expense;
    final amountPrefix = isCredit ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart, // swipe left to delete
      onDismissed: (_) => onDelete?.call(),
      // Red delete background revealed on swipe
      background: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: FinPilotTheme.expense.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FinPilotTheme.expense.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: FinPilotTheme.expense,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: FinPilotTheme.expense,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: Row(
          children: [
            // ── Category Icon ──────────────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(style.icon, color: style.color, size: 22),
            ),

            const SizedBox(width: 12),

            // ── Merchant + Category ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                          color: style.color.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // EMI badge
                      if (transaction.isEmi) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FinPilotTheme.warning.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: FinPilotTheme.warning.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            'EMI',
                            style: TextStyle(
                              color: FinPilotTheme.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      // Recurring badge
                      if (transaction.isRecurring) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FinPilotTheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: FinPilotTheme.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: const Text(
                            '↻',
                            style: TextStyle(
                              color: FinPilotTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Account name in muted small text
                  const SizedBox(height: 2),
                  Text(
                    transaction.source,
                    style: const TextStyle(color: Colors.white24, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  '$amountPrefix₹${_formatAmount(transaction.amount)}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(status: transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case TransactionStatus.completed:
        return const SizedBox.shrink(); // don't show badge for completed — it's the default
      case TransactionStatus.pending:
        color = FinPilotTheme.warning;
        label = 'Pending';
      case TransactionStatus.failed:
        color = FinPilotTheme.expense;
        label = 'Failed';
      case TransactionStatus.cancelled:
        color = Colors.white38;
        label = 'Cancelled';
      case TransactionStatus.reversed:
        color = FinPilotTheme.income;
        label = 'Reversed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
