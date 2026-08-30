// lib/features/import/presentation/widgets/idle_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class IdleView extends StatelessWidget {
  final VoidCallback onPickFile;
  final String? errorMessage;

  const IdleView({super.key, required this.onPickFile, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              size: 56,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Import Bank Statement',
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supports HDFC, SBI, ICICI, and Axis Bank\nstatements in PDF format.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FinPilotColors.expense.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FinPilotColors.expense.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: FinPilotColors.expense,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: FinPilotColors.expense,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Choose PDF File', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            children: ['HDFC', 'SBI', 'ICICI', 'Axis'].map((bank) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                  ),
                ),
                child: Text(
                  bank,
                  style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
