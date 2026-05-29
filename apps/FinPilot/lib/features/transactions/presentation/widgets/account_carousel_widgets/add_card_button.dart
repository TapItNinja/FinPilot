//lib/features/transactions/presentation/widgets/account_carousel_widgets/add_card_button.dart
// ── Add account card at end of carousel ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class AddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: FinPilotTheme.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: FinPilotTheme.primary.withValues(alpha: 0.4),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FinPilotTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: FinPilotTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add Account',
                style: TextStyle(
                  color: FinPilotTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
