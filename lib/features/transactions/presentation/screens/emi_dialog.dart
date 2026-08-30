// lib/features/transactions/presentation/screens/emi_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_notifier.dart';

class EmiDialog extends ConsumerStatefulWidget {
  final TransactionEntity transaction;

  const EmiDialog({super.key, required this.transaction});

  @override
  ConsumerState<EmiDialog> createState() => _EmiDialogState();
}

class _EmiDialogState extends ConsumerState<EmiDialog> {
  final _monthsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _confirmEmi() async {
    final months = int.tryParse(_monthsController.text.trim());
    if (months == null || months < 2 || months > 84) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number of months (2–84)')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final monthly = (widget.transaction.amount / months * 100).round() / 100;

    final updated = widget.transaction.copyWith(
      isEmi: true,
      emiMonthsTotal: months,
      emiMonthsRemaining: months,
      emiMonthlyAmount: monthly,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(transactionNotifierProvider.notifier)
        .updateTransaction(updated);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final amount = widget.transaction.amount.toStringAsFixed(2);

    return AlertDialog(
      backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'EMI Detected?',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FinPilotColors.warning.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: FinPilotColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: FinPilotColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '\$$amount debit from ${widget.transaction.merchant}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Was this purchase converted to EMI?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'If yes, enter the number of months so we can track your EMI schedule.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _monthsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Number of months',
              hintText: 'e.g. 6, 12, 24',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: 'months',
            ),
          ),

          ValueListenableBuilder(
            valueListenable: _monthsController,
            builder: (context, value, _) {
              final months = int.tryParse(value.text);
              if (months == null || months < 2) return const SizedBox.shrink();

              final monthly = (widget.transaction.amount / months)
                  .toStringAsFixed(2);
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '≈ \$$monthly / month',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Not an EMI',
            style: TextStyle(
              color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _confirmEmi,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm EMI'),
        ),
      ],
    );
  }
}
