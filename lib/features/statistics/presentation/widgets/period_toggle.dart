// lib/features/statistics/presentation/widgets/period_toggle.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';

class PeriodToggle extends StatelessWidget {
  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onChanged;

  const PeriodToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final onPrimary = isDark ? FinPilotColors.onPrimaryDark : Colors.white;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
        ),
      ),
      child: Row(
        children: StatsPeriod.values.map((p) {
          final isSelected = p == selected;
          final label = p.name[0].toUpperCase() + p.name.substring(1);

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected && isDark
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? onPrimary
                        : (isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
