// lib/features/statistics/presentation/widgets/category_donut_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';
import 'category_drilldown_sheet.dart';

class CategoryDonutChart extends StatefulWidget {
  final StatisticsData data;
  final StatsPeriod period;

  const CategoryDonutChart({
    super.key,
    required this.data,
    this.period = StatsPeriod.month,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  static const _colors = [
    FinPilotColors.primaryDark,
    FinPilotColors.chartOrange,
    FinPilotColors.chartBlue,
    FinPilotColors.chartYellow,
    FinPilotColors.chartPurple,
    FinPilotColors.chartPink,
  ];

  @override
  Widget build(BuildContext context) {
    final categories = widget.data.categoryBreakdown;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    if (categories.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Center(
          child: Text(
            'No category spending in this period',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    centerSpaceRadius: 44,
                    sectionsSpace: 2,
                    sections: categories.asMap().entries.map((e) {
                      final isTouched = e.key == _touchedIndex;
                      final color = _colors[e.key % _colors.length];
                      return PieChartSectionData(
                        value: e.value.amount,
                        color: color,
                        radius: isTouched ? 34 : 28,
                        title: isTouched
                            ? '${e.value.percentage.toStringAsFixed(0)}%'
                            : '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categories.asMap().entries.map((e) {
                    final color = _colors[e.key % _colors.length];
                    final isSelected = e.key == _touchedIndex;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        CategoryDrilldownSheet.show(
                          context,
                          e.value,
                          widget.period,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.value.category,
                                style: TextStyle(
                                  color: isDark
                                      ? FinPilotColors.darkTextPrimary
                                      : FinPilotColors.lightTextPrimary,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.value.percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: isSelected ? color : textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, size: 12, color: textMuted),
              const SizedBox(width: 4),
              Text(
                'Tap any category to view transactions',
                style: TextStyle(color: textMuted, fontSize: 10.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
