// ── Category Add Button ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/category_styles.dart';
class CategoryAddButton extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryAddButton({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = getCategoryStyle(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(style.icon, color: style.color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
