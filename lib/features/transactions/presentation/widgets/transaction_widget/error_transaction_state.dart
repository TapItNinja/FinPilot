// lib/features/transactions/presentation/widgets/transaction_widget/error_transaction_state.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class ErrorTransactionState extends StatelessWidget {
  final String error;

  const ErrorTransactionState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: FinPilotColors.expense,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
