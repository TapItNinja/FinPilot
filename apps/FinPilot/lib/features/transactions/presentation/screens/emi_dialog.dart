// WHY THIS FILE EXISTS:
// When a debit over ₹10,000 is detected, we show this dialog asking
// "Did you convert this to EMI?"
//
// If the user says yes, they enter the number of months and we update
// the transaction with EMI details via TransactionNotifier.updateTransaction().
//
// If they dismiss it, the transaction is saved as-is (not an EMI).
//
// This is a StatefulWidget because it has local state:
// the months field and the loading state while saving.
//lib/features/transactions/presentation/screens/emi_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    // Monthly amount = total / months, rounded to 2 decimal places
    final monthly = (widget.transaction.amount / months * 100).round() / 100;

    // Update the transaction with EMI details using copyWith
    final updated = widget.transaction.copyWith(
      isEmi: true,
      emiMonthsTotal: months,
      emiMonthsRemaining: months, // starts at full count
      emiMonthlyAmount: monthly,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(transactionNotifierProvider.notifier)
        .updateTransaction(updated);

    if (!mounted) return;
    Navigator.of(context).pop(); // close dialog
  }

  @override
  Widget build(BuildContext context) {
    // Format amount nicely for display
    final amount = widget.transaction.amount.toStringAsFixed(0);

    return AlertDialog(
      title: const Text('EMI Detected?'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // dialog only as tall as content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context — show the transaction details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '₹$amount debit from ${widget.transaction.merchant}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Was this purchase converted to EMI?',
            style: TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 4),

          Text(
            'If yes, enter the number of months so we can track your EMI schedule.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 16),

          // Months input — only shown if user wants to confirm EMI
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

          // Preview monthly amount as user types
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
                  '≈ ₹$monthly / month',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      actions: [
        // "Not an EMI" — dismisses without updating
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Not an EMI'),
        ),

        // "Yes, it's EMI" — saves EMI details
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
