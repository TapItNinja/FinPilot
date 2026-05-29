// ── Idle view ─────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class IdleView extends StatelessWidget {
  final VoidCallback onPickFile;
  final String? errorMessage;

  const IdleView({super.key, required this.onPickFile, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: FinPilotTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 56,
              color: FinPilotTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Import Bank Statement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supports HDFC, SBI, ICICI, and Axis Bank\nstatements in PDF format.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FinPilotTheme.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FinPilotTheme.expense.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: FinPilotTheme.expense,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: FinPilotTheme.expense,
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
              label: const Text('Choose PDF File'),
            ),
          ),

          const SizedBox(height: 12),

          // Supported banks chips
          Wrap(
            spacing: 8,
            children: ['HDFC', 'SBI', 'ICICI', 'Axis'].map((bank) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FinPilotTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FinPilotTheme.darkBorder),
                ),
                child: Text(
                  bank,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
