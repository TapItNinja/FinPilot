// lib/features/accounts/presentation/widgets/account_card_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';
import '../../domain/entities/account_entity.dart';

class AccountCardWidget extends StatelessWidget {
  final AccountEntity account;
  final double width;
  final double height;
  final bool isSelected;

  const AccountCardWidget({
    super.key,
    required this.account,
    this.width = double.infinity,
    this.height = 200,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = gradientForTheme(account.gradientTheme);
    final textColor = textColorForTheme(account.gradientTheme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 24 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    account.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  account.kind == AccountKind.creditCard
                      ? Icons.credit_card_rounded
                      : Icons.account_balance_rounded,
                  color: textColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                account.kind == AccountKind.creditCard ? 'CREDIT CARD' : 'BANK',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'XXXX ${account.last4Digits}',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}