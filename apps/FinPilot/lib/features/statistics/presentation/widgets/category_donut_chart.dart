import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';

class CategoryDonutChart extends StatefulWidget {
  final StatisticsData data;
  const CategoryDonutChart({super.key, required this.data});

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B6B),
    Color(0xFF2DC78B),
    Color(0xFFFFB347),
    Color(0xFF48DBFB),
    Color(0xFF8395A7),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = widget.data.categoryBreakdown;
    if (categories.isEmpty) {
      return Container(
        height: 200,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinPilotTheme.darkBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 160,
            width: 160,
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
                centerSpaceRadius: 48,
                sectionsSpace: 2,
                sections: categories.asMap().entries.map((e) {
                  final isTouched = e.key == _touchedIndex;
                  final color = _colors[e.key % _colors.length];
                  return PieChartSectionData(
                    value: e.value.amount,
                    color: color,
                    radius: isTouched ? 36 : 30,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: categories.asMap().entries.map((e) {
                final color = _colors[e.key % _colors.length];
                final isSelected = e.key == _touchedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value.category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${e.value.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: isSelected ? color : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
