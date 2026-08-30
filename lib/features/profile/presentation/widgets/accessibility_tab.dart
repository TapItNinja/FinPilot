// lib/features/profile/presentation/widgets/accessibility_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/accessibility/accessibility_notifier.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_notifier.dart';

class AccessibilityTab extends ConsumerWidget {
  const AccessibilityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final accessibilityState = ref.watch(accessibilityNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Theme Mode Section ──────────────────────────────────────────
        _SectionTitle(
          title: 'Appearance & Theme',
          subtitle: 'Choose your preferred visual presentation mode',
          icon: Icons.palette_outlined,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              _ThemeOptionTile(
                title: 'System',
                icon: Icons.brightness_auto_rounded,
                isSelected: currentThemeMode == ThemeMode.system,
                onTap: () {
                  if (accessibilityState.hapticsEnabled) HapticFeedback.selectionClick();
                  ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.system);
                },
              ),
              _ThemeOptionTile(
                title: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: currentThemeMode == ThemeMode.dark,
                onTap: () {
                  if (accessibilityState.hapticsEnabled) HapticFeedback.selectionClick();
                  ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
                },
              ),
              _ThemeOptionTile(
                title: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: currentThemeMode == ThemeMode.light,
                onTap: () {
                  if (accessibilityState.hapticsEnabled) HapticFeedback.selectionClick();
                  ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.light);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Text Scaling / Font Size Section ───────────────────────────
        _SectionTitle(
          title: 'Dynamic Text Scale',
          subtitle: 'Adjust text size for comfortable reading across the app',
          icon: Icons.text_fields_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Font Size Multiplier',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(accessibilityState.textScaleFactor * 100).toInt()}%',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<double>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return primaryColor;
                    }
                    return isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return isDark ? FinPilotColors.onPrimaryDark : Colors.white;
                    }
                    return isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;
                  }),
                ),
                segments: const [
                  ButtonSegment(value: 0.9, label: Text('Small')),
                  ButtonSegment(value: 1.0, label: Text('Default')),
                  ButtonSegment(value: 1.15, label: Text('Large')),
                  ButtonSegment(value: 1.3, label: Text('XL')),
                ],
                selected: {accessibilityState.textScaleFactor},
                onSelectionChanged: (Set<double> selected) {
                  if (accessibilityState.hapticsEnabled) HapticFeedback.selectionClick();
                  ref
                      .read(accessibilityNotifierProvider.notifier)
                      .setTextScaleFactor(selected.first);
                },
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2,
                  borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
                ),
                child: Text(
                  'Sample Text: \$2,408.45 Balance in PashaBank USD',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Visual & Tactile Accessibility ─────────────────────────────
        _SectionTitle(
          title: 'Visual & Tactile Controls',
          subtitle: 'Enhance contrast, motion, and tactile feedback',
          icon: Icons.accessibility_new_rounded,
        ),
        const SizedBox(height: 12),
        Material(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            side: BorderSide(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                activeThumbColor: primaryColor,
                title: Text(
                  'High Contrast Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Increases border and text contrast ratios',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                secondary: Icon(Icons.contrast_rounded, color: primaryColor),
                value: accessibilityState.isHighContrast,
                onChanged: (val) {
                  if (accessibilityState.hapticsEnabled) HapticFeedback.selectionClick();
                  ref
                      .read(accessibilityNotifierProvider.notifier)
                      .setHighContrast(val);
                },
              ),
              Divider(
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
              SwitchListTile(
                activeThumbColor: primaryColor,
                title: Text(
                  'Reduce Motion',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Minimizes animated screen transitions',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                secondary: Icon(Icons.motion_photos_off_rounded, color: primaryColor),
                value: accessibilityState.reduceMotion,
                onChanged: (val) {
                  if (accessibilityState.hapticsEnabled) HapticFeedback.selectionClick();
                  ref
                      .read(accessibilityNotifierProvider.notifier)
                      .setReduceMotion(val);
                },
              ),
              Divider(
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
              SwitchListTile(
                activeThumbColor: primaryColor,
                title: Text(
                  'Haptic Touch Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Vibrates subtly when tapping interactive elements',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                secondary: Icon(Icons.vibration_rounded, color: primaryColor),
                value: accessibilityState.hapticsEnabled,
                onChanged: (val) {
                  if (val) HapticFeedback.mediumImpact();
                  ref
                      .read(accessibilityNotifierProvider.notifier)
                      .setHapticsEnabled(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : (isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : primaryColor)
                      : (isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
