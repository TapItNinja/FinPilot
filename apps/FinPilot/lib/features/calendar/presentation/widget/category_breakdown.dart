// ── Category Breakdown ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> breakdown;
  final double totalSpent;

  const CategoryBreakdown({super.key, required this.breakdown, required this.totalSpent});

  static const _colors = [
    FinPilotTheme.primary,
    FinPilotTheme.expense,
    FinPilotTheme.income,
    FinPilotTheme.warning,
    Color(0xFF48DBFB),
    Color(0xFF8395A7),
  ];

  String _fmt(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxAmount = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FinPilotTheme.darkBorder),
      ),
      child: Column(
        children: sorted.asMap().entries.map((e) {
          final color = _colors[e.key % _colors.length];
          final pct = totalSpent > 0
              ? (e.value.value / totalSpent * 100).toStringAsFixed(0)
              : '0';
          final barFraction = maxAmount > 0 ? e.value.value / maxAmount : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          e.value.key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_fmt(e.value.value)}  $pct%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barFraction,
                    minHeight: 5,
                    backgroundColor: FinPilotTheme.darkSurface2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
