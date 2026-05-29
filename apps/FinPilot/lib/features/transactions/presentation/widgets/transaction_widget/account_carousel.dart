// lib/features/transactions/presentation/widgets/account_carousel.dart
//
// Individual mode carousel — center card large, side cards peeking.
// Swiping updates selectedAccountProvider which filters transactions + summary.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/account_carousel_widgets/account_label.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/account_carousel_widgets/add_card_button.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/account_carousel_widgets/carousel_card.dart';

class AccountCarousel extends ConsumerStatefulWidget {
  final List<AccountEntity> accounts;
  final VoidCallback onAddAccount;

  const AccountCarousel({
    super.key,
    required this.accounts,
    required this.onAddAccount,
  });

  @override
  ConsumerState<AccountCarousel> createState() => _AccountCarouselState();
}

class _AccountCarouselState extends ConsumerState<AccountCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  // All items = accounts + 1 add button at end
  int get _itemCount => widget.accounts.length + 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.72, // center card takes 72%, sides peek at 14% each
      initialPage: 0,
    );

    // Set initial selected account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.accounts.isNotEmpty) {
        ref
            .read(selectedAccountProvider.notifier)
            .select(widget.accounts.first);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);

    // Update selected account — if on add card, keep last account selected
    if (page < widget.accounts.length) {
      ref.read(selectedAccountProvider.notifier).select(widget.accounts[page]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accounts.isEmpty) {
      return AddCardButton(onTap: widget.onAddAccount);
    }

    return Column(
      children: [
        // ── Card Carousel ────────────────────────────────────────────
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _itemCount,
            itemBuilder: (context, index) {
              // Last item = add account card
              if (index == widget.accounts.length) {
                return AddCardButton(onTap: widget.onAddAccount);
              }

              final account = widget.accounts[index];
              final isCenter = index == _currentPage;

              return AnimatedScale(
                scale: isCenter ? 1.0 : 0.88,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: isCenter ? 1.0 : 0.55,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: CarouselCard(account: account),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Account name + indicator ─────────────────────────────────
        if (_currentPage < widget.accounts.length)
          AccountLabel(
            account: widget.accounts[_currentPage],
            allAccounts: widget.accounts,
            currentPage: _currentPage,
          ),
      ],
    );
  }
}



