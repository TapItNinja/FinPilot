// lib/core/utils/card_gradient_helper.dart
//
// Single source of truth for account card gradients.
// Previously duplicated across transaction_screen.dart,
// account_carousel.dart, and add_transaction_screen.dart.
// All of those now import from here.

import 'package:flutter/material.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';

LinearGradient gradientForTheme(CardGradientTheme theme) {
  switch (theme) {
    case CardGradientTheme.indigoPurple:
      return const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.orangeRed:
      return const LinearGradient(
        colors: [Color(0xFFFF9A44), Color(0xFFFC6076)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.tealBlue:
      return const LinearGradient(
        colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.pinkLavender:
      return const LinearGradient(
        colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.darkSlate:
      return const LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF3D5A80)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.pinkCoral:
      return const LinearGradient(
        colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.peachCream:
      return const LinearGradient(
        colors: [Color(0xFFFFDAB9), Color(0xFFFFB347)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.mintGreen:
      return const LinearGradient(
        colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.crimsonRed:
      return const LinearGradient(
        colors: [Color(0xFFCB2D3E), Color(0xFFEF473A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case CardGradientTheme.midnightBlue:
      return const LinearGradient(
        colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

// Text color for a given gradient — light gradients need dark text
Color textColorForTheme(CardGradientTheme theme) {
  switch (theme) {
    case CardGradientTheme.pinkLavender:
    case CardGradientTheme.peachCream:
      return const Color(0xFF1A1A2E);
    default:
      return Colors.white;
  }
}
