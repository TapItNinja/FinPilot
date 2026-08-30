// lib/features/onboarding/presentation/widgets/pad_key.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class PadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const PadKey({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
