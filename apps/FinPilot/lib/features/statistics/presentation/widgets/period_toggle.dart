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
    return Container(
      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: FinPilotTheme.darkBorder),
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
                  color: isSelected
                      ? FinPilotTheme.primary
                      : Colors.transparent,

                  borderRadius: BorderRadius.circular(8),
                ),

                child: Text(
                  label,
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,

                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,

                    fontSize: 14,
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
