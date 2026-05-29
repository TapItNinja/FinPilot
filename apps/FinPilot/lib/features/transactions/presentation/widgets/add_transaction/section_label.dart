//lib/features/transactions/presentation/widgets/add_transaction/section_label.dart
// ── Section Label ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  // ignore: use_key_in_widget_constructors
  const SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
