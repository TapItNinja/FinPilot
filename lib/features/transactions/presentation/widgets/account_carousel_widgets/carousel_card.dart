//lib/features/transactions/presentation/widgets/account_carousel_widgets/carousel_card.dart
// ── Individual carousel card ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';

class CarouselCard extends StatelessWidget {
  final AccountEntity account;

  const CarouselCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final gradient = gradientForTheme(account.gradientTheme);
    final textColor = textColorForTheme(account.gradientTheme);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  account.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
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
    );
  }
}
