// lib/features/onboarding/presentation/widgets/number_pad.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/onboarding/presentation/widgets/pad_key.dart';

class NumberPad extends StatelessWidget {
  final void Function(String digit) onDigitTap;
  final VoidCallback onDelete;

  const NumberPad({super.key, required this.onDigitTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;

    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 80);
                }
                if (key == 'del') {
                  return PadKey(
                    onTap: onDelete,
                    child: Icon(
                      Icons.backspace_outlined,
                      color: textSecondary,
                      size: 22,
                    ),
                  );
                }
                return PadKey(
                  child: Text(
                    key,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => onDigitTap(key),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
