import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

import '../providers/statistics_notifier.dart';

class SummaryRow extends StatelessWidget {
  final StatisticsData data;
  const SummaryRow({super.key, required this.data});

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryTile(
            label: 'Total Spent',
            value: '₹${_fmt(data.totalSpent)}',
            color: FinPilotTheme.expense,
            icon: Icons.north_east_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryTile(
            label: 'Total Income',
            value: '₹${_fmt(data.totalIncome)}',
            color: FinPilotTheme.income,
            icon: Icons.south_west_rounded,
          ),
        ),
      ],
    );
  }
}

class SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const SummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinPilotTheme.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
