// ── No Selection Hint ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class NoSelectionHint extends StatelessWidget {
  const NoSelectionHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FinPilotTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              size: 36,
              color: FinPilotTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap a date to see transactions',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
