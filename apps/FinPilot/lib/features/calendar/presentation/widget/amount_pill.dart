// ── Amount Pill ───────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AmountPill extends StatelessWidget {
  final double amount;
  final Color color;
  final String prefix;

  const AmountPill({
    super.key,
    required this.amount,
    required this.color,
    required this.prefix,
  });

  String _fmt(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    }
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$prefix₹${_fmt(amount)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
