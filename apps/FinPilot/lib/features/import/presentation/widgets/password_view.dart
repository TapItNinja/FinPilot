// ── Password view ─────────────────────────────────────────────────────────────
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FinPilotTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FinPilotTheme.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: FinPilotTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Password protected?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Most bank statements are password protected. Enter the password below, or leave blank if yours is not.',
            style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'PDF Password',
              hintText: 'Leave blank if no password',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.white38,
              ),
              errorText: errorMessage,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FinPilotTheme.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FinPilotTheme.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: FinPilotTheme.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'For most Indian banks, the password is your date of birth (DDMMYYYY) or PAN number. Check the email you received with the statement.',
                    style: TextStyle(
                      color: Colors.white54,
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
                    side: const BorderSide(color: FinPilotTheme.darkBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'No Password',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
