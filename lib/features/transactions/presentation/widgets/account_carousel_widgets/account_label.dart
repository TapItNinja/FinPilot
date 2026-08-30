//lib/features/transactions/presentation/widgets/account_carousel_widgets/account_label.dart
// ── Account name + page indicator below carousel ──────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';

class AccountLabel extends StatelessWidget {
  final AccountEntity account;
  final List<AccountEntity> allAccounts;
  final int currentPage;

  const AccountLabel({
    super.key,
    required this.account,
    required this.allAccounts,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Account name
        Text(
          account.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // Page dots / underline indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(allAccounts.length, (index) {
            final isSelected = index == currentPage;
            final gradient = gradientForTheme(allAccounts[index].gradientTheme);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 28 : 6,
              height: 4,
              decoration: BoxDecoration(
                gradient: isSelected ? gradient : null,
                color: isSelected ? null : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
