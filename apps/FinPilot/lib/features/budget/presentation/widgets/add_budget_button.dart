// ── Add Budget Button ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
class AddBudgetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddBudgetButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FinPilotTheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: FinPilotTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: FinPilotTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: FinPilotTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
