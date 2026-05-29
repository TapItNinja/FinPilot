import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class PadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const PadKey({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          shape: BoxShape.circle,
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: Center(child: child),
      ),
    );
  }
}
