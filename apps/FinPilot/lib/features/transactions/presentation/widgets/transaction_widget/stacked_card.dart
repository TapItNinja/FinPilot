//lib/features/transactions/presentation/widgets/transaction_widget/stacked_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/account_card_simple.dart';

class StackedCards extends StatelessWidget {
  final List<AccountEntity> accounts;

  const StackedCards({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox(height: 180);

    final cardWidth = MediaQuery.of(context).size.width - 64;

    return SizedBox(
      height: 210,
      child: Swiper(
        itemCount: accounts.length,
        itemWidth: cardWidth,
        itemHeight: 180,
        layout: SwiperLayout.STACK,
        loop: true,
        duration: 400,
        itemBuilder: (context, index) {
          return AccountCardSimple(
            account: accounts[index],
            height: 180,
            opacity: 1.0,
          );
        },
      ),
    );
  }
}
