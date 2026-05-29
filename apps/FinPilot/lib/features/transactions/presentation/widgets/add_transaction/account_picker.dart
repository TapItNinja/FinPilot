// lib/features/transactions/presentation/widgets/add_transaction/account_picker.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class AccountPicker extends StatelessWidget {
  final List<AccountEntity> accounts;
  final AccountEntity? selected;
  final ValueChanged<AccountEntity> onSelected;

  const AccountPicker({
    super.key,
    required this.accounts,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: const Text(
          'No accounts added yet. Add one from the home screen.',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final account = accounts[index];
          final isSelected = selected?.id == account.id;
          final gradient = gradientForTheme(account.gradientTheme);

          return GestureDetector(
            onTap: () => onSelected(account),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: gradient.colors.first.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          account.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'XXXX ${account.last4Digits}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
