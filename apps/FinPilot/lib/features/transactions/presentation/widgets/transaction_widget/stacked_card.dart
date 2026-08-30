// lib/features/transactions/presentation/widgets/transaction_widget/stacked_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/account_card_widget.dart';

class StackedCards extends StatelessWidget {
  final List<AccountEntity> accounts;
  final ValueChanged<int>? onIndexChanged;
  final int initialIndex;

  // Real-life ISO/IEC 7810 ID-1 standard credit card aspect ratio (85.60mm x 53.98mm)
  static const double creditCardAspectRatio = 85.60 / 53.98; // ~1.58577

  const StackedCards({
    super.key,
    required this.accounts,
    this.onIndexChanged,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 36;
    final cardHeight = cardWidth / creditCardAspectRatio;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (accounts.isEmpty) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blueAccent.withValues(alpha: isDark ? 0.3 : 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -20,
              child: Opacity(
                opacity: 0.04,
                child: Icon(Icons.ac_unit_rounded, size: 160, color: isDark ? Colors.white : Colors.black),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: isDark ? 0.15 : 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.ac_unit_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'All Cards are Frozen',
                      style: TextStyle(
                        color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unfreeze your cards in Profile & Settings\nto restore active card tracking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (accounts.length == 1) {
      return SizedBox(
        height: cardHeight + 14,
        width: cardWidth,
        child: Center(
          child: AccountCardWidget(
            key: ValueKey('card_${accounts[0].id}'),
            account: accounts[0],
            width: cardWidth,
            height: cardHeight,
          ),
        ),
      );
    }

    return SizedBox(
      height: cardHeight + 14,
      child: Swiper(
        key: ValueKey('swiper_${accounts.map((a) => a.id).join('_')}'),
        index: initialIndex < accounts.length ? initialIndex : 0,
        itemCount: accounts.length,
        itemWidth: cardWidth,
        itemHeight: cardHeight,
        layout: SwiperLayout.STACK,
        loop: true,
        duration: 300,
        onIndexChanged: onIndexChanged,
        itemBuilder: (context, index) {
          final acc = accounts[index];
          return AccountCardWidget(
            key: ValueKey('card_${acc.id}'),
            account: acc,
            height: cardHeight,
          );
        },
      ),
    );
  }
}
