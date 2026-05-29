//lib/features/transactions/presentation/widgets/transaction_widget/grouped_transaction_sliver.dart
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

    for (final entry in grouped.entries) {
      items.add(entry.key);
      items.addAll(entry.value);
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

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

                      backgroundColor: FinPilotTheme.darkSurface2,

                      action: SnackBarAction(
                        label: 'Undo',

                        textColor: FinPilotTheme.primary,

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
    final dayTotal = items
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            label,

            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),

          if (dayTotal > 0)
            Text(
              '- ₹${dayTotal.toStringAsFixed(0)}',

              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
