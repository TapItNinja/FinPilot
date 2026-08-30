// lib/core/utils/card_gradient_helper.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';

LinearGradient gradientForTheme(CardGradientTheme theme, {bool isDark = true}) {
  if (isDark) {
    switch (theme) {
      case CardGradientTheme.indigoPurple:
        return const LinearGradient(
          colors: [Color(0xFF2E2B5F), Color(0xFF4A3B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.orangeRed:
        return const LinearGradient(
          colors: [Color(0xFF5A2A27), Color(0xFF8C3E38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.tealBlue:
        return const LinearGradient(
          colors: [Color(0xFF133B3A), Color(0xFF1B5E57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.pinkLavender:
        return const LinearGradient(
          colors: [Color(0xFF4A3048), Color(0xFF6B4567)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.darkSlate:
        return const LinearGradient(
          colors: [Color(0xFF1E2638), Color(0xFF2C384E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.pinkCoral:
        return const LinearGradient(
          colors: [Color(0xFF54253B), Color(0xFF7A3654)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.peachCream:
        return const LinearGradient(
          colors: [Color(0xFF4E3827), Color(0xFF70523A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.mintGreen:
        return const LinearGradient(
          colors: [Color(0xFF183C28), Color(0xFF245B3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.crimsonRed:
        return const LinearGradient(
          colors: [Color(0xFF501920), Color(0xFF782530)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.midnightBlue:
        return const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  } else {
    // Light Mode luxury palettes — clean, crisp, premium frosted finishes
    switch (theme) {
      case CardGradientTheme.indigoPurple:
        return const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.orangeRed:
        return const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.tealBlue:
        return const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.pinkLavender:
        return const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.darkSlate:
        return const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.pinkCoral:
        return const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.peachCream:
        return const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.mintGreen:
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.crimsonRed:
        return const LinearGradient(
          colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardGradientTheme.midnightBlue:
        return const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

Color textColorForTheme(CardGradientTheme theme, {bool isDark = true}) {
  return Colors.white;
}
