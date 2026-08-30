// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard layout & dimension constants for consistent UI across FinPilot
class CardDimensions {
  static const double borderRadius = 20.0;
  static const double borderRadiusSmall = 12.0;
  static const double creditCardAspectRatio = 85.60 / 53.98; // ~1.58577 ISO/IEC 7810 ID-1
  static const double accountCardHeight = 190.0;
  static const double summaryCardHeight = 96.0;
  static const EdgeInsets paddingStandard = EdgeInsets.all(16.0);
  static const EdgeInsets paddingCompact = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
}

/// Central Color Palette & Design Tokens
/// All app colors are declared here to allow future dynamic theme switching.
class FinPilotColors {
  // ── Signature Brand Accent (Reference Lime Theme) ─────────────────────
  static const primaryDark = Color(0xFFC6F432); // Vibrant Lime Green for Dark Mode
  static const primaryLight = Color(0xFF16A34A); // Emerald Forest for Light Mode
  static const onPrimaryDark = Color(0xFF0C0E12); // Dark text on Lime FAB
  static const onPrimaryLight = Colors.white;

  // ── Financial Semantic Colors ─────────────────────────────────────────
  static const income = Color(0xFF22C55E); // Emerald Cash Inflow
  static const expense = Color(0xFFF43F5E); // Crimson Cash Outflow
  static const warning = Color(0xFFF59E0B); // Amber Warning
  static const info = Color(0xFF38BDF8); // Cyan Info

  // ── Multi-color Category & Chart Accents (from reference design) ──────
  static const chartOrange = Color(0xFFF97316);
  static const chartBlue = Color(0xFF38BDF8);
  static const chartYellow = Color(0xFFFBBF24);
  static const chartPurple = Color(0xFFA855F7);
  static const chartEmerald = Color(0xFF10B981);
  static const chartPink = Color(0xFFEC4899);

  // ── Dark Theme Surfaces & Typography ──────────────────────────────────
  static const darkBg = Color(0xFF0C0E12); // Obsidian Matte Black
  static const darkSurface = Color(0xFF171A21); // Card Surface
  static const darkSurface2 = Color(0xFF212530); // Elevated Tile / Input
  static const darkBorder = Color(0xFF282D3B); // Border Slate
  static const darkTextPrimary = Colors.white;
  static const darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const darkTextMuted = Color(0xFF64748B); // Slate 500

  // ── High Contrast Dark Surfaces ───────────────────────────────────────
  static const hcDarkBg = Color(0xFF000000);
  static const hcDarkSurface = Color(0xFF0D1117);
  static const hcDarkBorder = Color(0xFF475569);

  // ── Light Theme Surfaces & Typography ─────────────────────────────────
  static const lightBg = Color(0xFFF8FAFC); // Clean Soft White
  static const lightSurface = Color(0xFFFFFFFF); // Pure Card Surface
  static const lightSurface2 = Color(0xFFF1F5F9); // Light Slate Tile
  static const lightBorder = Color(0xFFE2E8F0); // Light Border
  static const lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const lightTextSecondary = Color(0xFF475569); // Slate 600
  static const lightTextMuted = Color(0xFF94A3B8); // Slate 400
}

class FinPilotTheme {
  // Backward compatible shorthand getters
  static const primary = FinPilotColors.primaryDark;
  static const primaryLight = FinPilotColors.primaryLight;
  static const income = FinPilotColors.income;
  static const expense = FinPilotColors.expense;
  static const warning = FinPilotColors.warning;
  static const darkBg = FinPilotColors.darkBg;
  static const darkSurface = FinPilotColors.darkSurface;
  static const darkSurface2 = FinPilotColors.darkSurface2;
  static const darkBorder = FinPilotColors.darkBorder;
  static const lightBg = FinPilotColors.lightBg;
  static const lightSurface = FinPilotColors.lightSurface;
  static const lightSurface2 = FinPilotColors.lightSurface2;
  static const lightBorder = FinPilotColors.lightBorder;

  static ThemeData dark({bool isHighContrast = false}) {
    final bg = isHighContrast ? FinPilotColors.hcDarkBg : FinPilotColors.darkBg;
    final surface = isHighContrast ? FinPilotColors.hcDarkSurface : FinPilotColors.darkSurface;
    final border = isHighContrast ? FinPilotColors.hcDarkBorder : FinPilotColors.darkBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: FinPilotColors.primaryDark,
        onPrimary: FinPilotColors.onPrimaryDark,
        secondary: FinPilotColors.chartBlue,
        surface: surface,
        error: FinPilotColors.expense,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        dividerHeight: 0.0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
          side: BorderSide(color: border, width: isHighContrast ? 1.5 : 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FinPilotColors.primaryDark,
          foregroundColor: FinPilotColors.onPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isHighContrast ? Colors.black : FinPilotColors.darkSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: const BorderSide(color: FinPilotColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: const BorderSide(color: FinPilotColors.expense),
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FinPilotColors.primaryDark,
        foregroundColor: FinPilotColors.onPrimaryDark,
        elevation: 6,
        shape: CircleBorder(),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 15),
        bodyMedium: TextStyle(color: FinPilotColors.darkTextSecondary, fontSize: 13),
        bodySmall: TextStyle(color: FinPilotColors.darkTextMuted, fontSize: 12),
        labelLarge: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData light({bool isHighContrast = false}) {
    final bg = isHighContrast ? Colors.white : FinPilotColors.lightBg;
    final surface = FinPilotColors.lightSurface;
    final border = isHighContrast ? const Color(0xFF64748B) : FinPilotColors.lightBorder;
    final textColor = FinPilotColors.lightTextPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary: FinPilotColors.primaryLight,
        onPrimary: FinPilotColors.onPrimaryLight,
        secondary: FinPilotColors.chartBlue,
        surface: surface,
        error: FinPilotColors.expense,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        dividerHeight: 0.0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isHighContrast ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
          side: BorderSide(color: border, width: isHighContrast ? 1.5 : 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FinPilotColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FinPilotColors.lightSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
          borderSide: const BorderSide(color: FinPilotColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: surface,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FinPilotColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textColor, fontSize: 15),
        bodyMedium: TextStyle(color: FinPilotColors.lightTextSecondary, fontSize: 13),
        bodySmall: TextStyle(color: FinPilotColors.lightTextMuted, fontSize: 12),
        labelLarge: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
