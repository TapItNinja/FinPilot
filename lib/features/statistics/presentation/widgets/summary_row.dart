// lib/features/statistics/presentation/widgets/summary_row.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';

class SummaryRow extends StatelessWidget {
  final StatisticsData data;
  const SummaryRow({super.key, required this.data});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
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
            value: '\$${_fmt(data.totalSpent)}',
            color: FinPilotColors.expense,
            icon: Icons.north_east_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryTile(
            label: 'Total Income',
            value: '\$${_fmt(data.totalIncome)}',
            color: FinPilotColors.income,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
