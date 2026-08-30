// lib/features/transactions/presentation/widgets/transaction_widget/grouped_transaction_sliver.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/transaction_notifier.dart';
import 'transaction_card.dart';

class GroupedTransactionSliver extends StatelessWidget {
  final Map<String, List<TransactionEntity>> grouped;
  final WidgetRef ref;

  const GroupedTransactionSliver({
    super.key,
    required this.grouped,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final items = <dynamic>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    for (final entry in grouped.entries) {
      items.add(entry.key);
      items.addAll(entry.value);
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];

          if (item is String) {
            return DateHeader(label: item, items: grouped[item]!);
          }

          if (item is TransactionEntity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TransactionCard(
                transaction: item,
                onDelete: () {
                  ref
                      .read(transactionNotifierProvider.notifier)
                      .deleteTransaction(item.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.merchant} deleted'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight,
                        onPressed: () {
                          ref
                              .read(transactionNotifierProvider.notifier)
                              .importTransactions([item]);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        }, childCount: items.length),
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  final String label;
  final List<TransactionEntity> items;

  const DateHeader({super.key, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayTotal = items
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          if (dayTotal > 0)
            Text(
              '-\$${dayTotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
