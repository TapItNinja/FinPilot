// lib/features/import/presentation/widgets/password_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class PasswordView extends StatelessWidget {
  final String fileName;
  final TextEditingController controller;
  final String? errorMessage;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PasswordView({
    super.key,
    required this.fileName,
    required this.controller,
    required this.onContinue,
    required this.onSkip,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf_rounded,
                  color: primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Password protected?',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Most bank statements are password protected. Enter the password below, or leave blank if yours is not.',
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'PDF Password',
              hintText: 'Leave blank if no password',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: textSecondary,
              ),
              errorText: errorMessage,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FinPilotColors.warning.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FinPilotColors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: FinPilotColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For most banks, the password is your date of birth (DDMMYYYY) or account number / PAN number. Check the email you received with the statement.',
                    style: TextStyle(
                      color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'No Password',
                    style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
