//lib/features/transactions/presentation/widgets/transaction_widget/empty_transaction_state.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class EmptyTransactionState extends StatelessWidget {
  const EmptyTransactionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: FinPilotTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: FinPilotTheme.primary,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No transactions yet',

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tap + to add your first transaction',

            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
