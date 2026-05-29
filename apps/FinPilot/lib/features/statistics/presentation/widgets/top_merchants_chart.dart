import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';

class TopMerchantsChart extends StatelessWidget {
  final StatisticsData data;
  const TopMerchantsChart({super.key, required this.data});

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  Color _barColor(int index) {
    const colors = [
      FinPilotTheme.primary,
      FinPilotTheme.expense,
      FinPilotTheme.income,
      FinPilotTheme.warning,
      Color(0xFF48DBFB),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final merchants = data.topMerchants;
    if (merchants.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: const Center(
          child: Text(
            'No spending data yet',
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    final maxAmount = merchants.first.amount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinPilotTheme.darkBorder),
      ),
      child: Column(
        children: merchants.asMap().entries.map((e) {
          final merchant = e.value;
          final barFraction = maxAmount > 0 ? merchant.amount / maxAmount : 0.0;
          final color = _barColor(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      merchant.merchant,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${_fmt(merchant.amount)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barFraction,
                    minHeight: 6,
                    backgroundColor: FinPilotTheme.darkSurface2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color.withValues(alpha: 0.8),
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
