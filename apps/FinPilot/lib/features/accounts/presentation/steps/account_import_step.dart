// ── Step 4: Import method + Created celebration ───────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/account_card_widget.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class Step4ImportMethod extends StatelessWidget {
  final AccountEntity account;
  final bool isFirstSetup;
  final VoidCallback onDone;

  const Step4ImportMethod({
    super.key,
    required this.account,
    required this.isFirstSetup,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Account card preview
          AccountCardWidget(account: account, height: 140),

          const SizedBox(height: 20),

          // Celebration
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 6),
          const Text(
            'Account Created!',
            style: TextStyle(
              color: FinPilotTheme.income,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'How would you like to add your transactions?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 16),

          _ImportOption(
            icon: Icons.edit_rounded,
            label: 'Enter Manually',
            subtitle: 'Add your expenses and income one at a time.',
            onTap: onDone,
          ),
          const SizedBox(height: 10),
          _ImportOption(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Import a PDF',
            subtitle: 'Upload a bank statement from Files.app.',
            onTap: onDone,
          ),
          const SizedBox(height: 10),
          _ImportOption(
            icon: Icons.email_rounded,
            label: 'Sync from Email',
            subtitle:
                'Automatically fetches PDF statements and transaction alerts from your email.',
            onTap: onDone,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDone,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: FinPilotTheme.darkBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ImportOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FinPilotTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: FinPilotTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.radio_button_unchecked_rounded,
              color: FinPilotTheme.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
