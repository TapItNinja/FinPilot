//lib/features/transactions/presentation/widgets/transaction_widget/transaction_section_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class TransactionSectionHeader extends StatelessWidget {
  final AsyncValue transactionState;

  const TransactionSectionHeader({super.key, required this.transactionState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text('Transactions', style: Theme.of(context).textTheme.titleMedium),

          transactionState.when(
            loading: () => const SizedBox.shrink(),

            error: (error, stackTrace) => const SizedBox.shrink(),

            data: (list) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: FinPilotTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  '${list.length} total',

                  style: const TextStyle(
                    color: FinPilotTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
