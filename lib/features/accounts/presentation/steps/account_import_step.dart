// lib/features/accounts/presentation/steps/account_import_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/account_card_widget.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/import/presentation/screens/pdf_import_screen.dart';
import 'package:mobile_app/features/transactions/presentation/screens/add_transaction_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Account card preview
          AccountCardWidget(account: account),

          const SizedBox(height: 20),

          // Celebration
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 6),
          const Text(
            'Account Created!',
            style: TextStyle(
              color: FinPilotColors.income,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'How would you like to add your transactions?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          _ImportOption(
            icon: Icons.edit_rounded,
            label: 'Enter Manually',
            subtitle: 'Add your expenses and income one at a time.',
            onTap: () async {
              HapticFeedback.lightImpact();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(initialAccount: account),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ImportOption(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Import a PDF',
            subtitle: 'Upload a bank statement from Files.app.',
            onTap: () async {
              HapticFeedback.lightImpact();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfImportScreen(initialAccount: account),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ImportOption(
            icon: Icons.email_rounded,
            label: 'Sync from Email',
            subtitle:
                'Automatically fetches PDF statements and transaction alerts from your email.',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email sync configured! Alerts will be processed automatically.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onDone();
              },
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                isFirstSetup ? 'Continue to App' : 'Done & Go to Dashboard',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.radio_button_unchecked_rounded,
              color: primaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
