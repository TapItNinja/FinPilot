// lib/features/statistics/presentation/widgets/top_merchants_chart.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';
import 'merchant_drilldown_sheet.dart';

class TopMerchantsChart extends StatelessWidget {
  final StatisticsData data;
  final StatsPeriod period;

  const TopMerchantsChart({
    super.key,
    required this.data,
    this.period = StatsPeriod.month,
  });

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  Color _barColor(int index) {
    const colors = [
      FinPilotColors.primaryDark,
      FinPilotColors.expense,
      FinPilotColors.income,
      FinPilotColors.warning,
      FinPilotColors.chartBlue,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final merchants = data.topMerchants;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    if (merchants.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Center(
          child: Text(
            'No merchant spending in this period',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ),
      );
    }

    final maxAmount = merchants.first.amount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          ...merchants.asMap().entries.map((e) {
            final merchant = e.value;
            final barFraction = maxAmount > 0 ? merchant.amount / maxAmount : 0.0;
            final color = _barColor(e.key);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                MerchantDrilldownSheet.show(context, merchant, period);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              merchant.merchant,
                              style: TextStyle(
                                color: isDark
                                    ? FinPilotColors.darkTextPrimary
                                    : FinPilotColors.lightTextPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: textMuted,
                            ),
                          ],
                        ),
                        Text(
                          '\$${_fmt(merchant.amount)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
                        backgroundColor: isDark
                            ? FinPilotColors.darkSurface2
                            : FinPilotColors.lightSurface2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, size: 12, color: textMuted),
              const SizedBox(width: 4),
              Text(
                'Tap any merchant to view visits and log',
                style: TextStyle(color: textMuted, fontSize: 10.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
