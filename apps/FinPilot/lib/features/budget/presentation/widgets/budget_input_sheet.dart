// ── Budget Input Bottom Sheet ─────────────────────────────────────────────────
// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
class BudgetInputSheet extends StatefulWidget {
  final String title;
  final double? current;
  final void Function(double) onSave;
  final VoidCallback? onDelete;

  const BudgetInputSheet({
    super.key,
    required this.title,
    required this.onSave,
    this.current,
    // ignore: duplicate_ignore
    // ignore: unused_element_parameter
    this.onDelete,
  });

  @override
  State<BudgetInputSheet> createState() => _BudgetInputSheetState();
}

class _BudgetInputSheetState extends State<BudgetInputSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.current != null ? widget.current!.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: FinPilotTheme.expense,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Amount input with ₹ prefix
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 32),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quick amount chips
          Wrap(
            spacing: 8,
            children: [5000, 10000, 15000, 20000, 50000].map((amount) {
              return GestureDetector(
                onTap: () =>
                    setState(() => _controller.text = amount.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: FinPilotTheme.darkSurface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FinPilotTheme.darkBorder),
                  ),
                  child: Text(
                    '₹${amount >= 1000 ? '${amount ~/ 1000}K' : amount}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_controller.text);
                if (amount == null || amount <= 0) {
                  return;
                }
                widget.onSave(amount);
              },
              child: Text(
                widget.current != null ? 'Update Budget' : 'Set Budget',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
