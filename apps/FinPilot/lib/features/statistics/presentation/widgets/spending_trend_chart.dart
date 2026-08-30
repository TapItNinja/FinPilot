// lib/features/statistics/presentation/widgets/spending_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/chart_legend_item.dart';
import '../providers/statistics_notifier.dart';

class SpendingTrendChart extends StatelessWidget {
  final StatisticsData data;
  final StatsPeriod period;
  const SpendingTrendChart({super.key, required this.data, required this.period});

  String _fmtAxis(double v) {
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}K';
    return '\$${v.toStringAsFixed(0)}';
  }

  double _xInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 31) return 5;
    return 30;
  }

  String _monthShort(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    if (data.dailySpend.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'No spending data yet',
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final spots = data.dailySpend
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
        .toList();

    final budgetSpots = [
      FlSpot(0, data.dailyBudgetLine),
      FlSpot((data.dailySpend.length - 1).toDouble(), data.dailyBudgetLine),
    ];

    final maxY =
        ((data.maxDailySpend > data.dailyBudgetLine
            ? data.maxDailySpend
            : data.dailyBudgetLine) *
        1.2);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              LegendItem(color: primaryColor, label: 'Actual'),
              const SizedBox(width: 16),
              const LegendItem(color: FinPilotColors.warning, label: 'Daily budget'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(),
                minY: 0,
                maxY: maxY == 0 ? 1000 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: borderColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          _fmtAxis(value),
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _xInterval(data.dailySpend.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= data.dailySpend.length) {
                          return const SizedBox.shrink();
                        }
                        final date = data.dailySpend[idx].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            period == StatsPeriod.year
                                ? _monthShort(date.month)
                                : '${date.day}',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: primaryColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.y > 0,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 3,
                            color: primaryColor,
                            strokeWidth: 2,
                            strokeColor: surfaceColor,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.25),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: budgetSpots,
                    isCurved: false,
                    color: FinPilotColors.warning,
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 1) {
                          return null;
                        }
                        final idx = spot.x.toInt();
                        String dateLabel = '';
                        if (idx >= 0 && idx < data.dailySpend.length) {
                          final d = data.dailySpend[idx].date;
                          dateLabel = '\n${_monthShort(d.month)} ${d.day}';
                        }
                        return LineTooltipItem(
                          '\$${spot.y.toStringAsFixed(2)}$dateLabel',
                          TextStyle(
                            color: isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
