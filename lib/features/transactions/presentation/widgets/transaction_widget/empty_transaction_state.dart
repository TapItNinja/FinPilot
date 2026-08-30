// lib/features/transactions/presentation/widgets/transaction_widget/empty_transaction_state.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class EmptyTransactionState extends StatelessWidget {
  const EmptyTransactionState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first transaction',
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
