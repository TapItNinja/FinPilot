// lib/features/transactions/presentation/widgets/transaction_widget/transaction_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_notifier.dart';
import 'package:mobile_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile_app/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:mobile_app/features/transactions/presentation/screens/transaction_screen.dart';

// ── Pinned App Bar with greeting, toggle, add button, and theme switcher ─────
class TransactionAppBar extends StatelessWidget {
  final AccountViewMode viewMode;
  final WidgetRef ref;
  final ValueChanged<AccountViewMode>? onModeChanged;

  const TransactionAppBar({
    super.key,
    required this.viewMode,
    required this.ref,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final onPrimary = isDark ? FinPilotColors.onPrimaryDark : Colors.white;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? FinPilotColors.darkBg : FinPilotColors.lightBg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? FinPilotColors.darkBorder.withValues(alpha: 0.5) : FinPilotColors.lightBorder.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── User Avatar + Greeting ──────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Farida Orujova',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Overall / Individual Mode Toggle ────────────────────
          _ModeToggle(
            viewMode: viewMode,
            onChanged: (mode) {
              if (onModeChanged != null) {
                onModeChanged!(mode);
              } else {
                ref.read(accountViewModeProvider.notifier).toggle(mode);
              }
            },
          ),

          const SizedBox(width: 8),

          // ── Quick Add Transaction Button ────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.add_rounded, color: onPrimary, size: 20),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ── Quick Moon/Sun Theme Toggle ─────────────────────────
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface2,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 16,
                color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
              ),
            ),
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              ref.read(themeNotifierProvider.notifier).setThemeMode(newMode);
            },
          ),
        ],
      ),
    );
  }
}

// ── Overall / Individual toggle ───────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final AccountViewMode viewMode;
  final ValueChanged<AccountViewMode> onChanged;

  const _ModeToggle({required this.viewMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'All',
            isSelected: viewMode == AccountViewMode.overall,
            onTap: () => onChanged(AccountViewMode.overall),
          ),
          const SizedBox(width: 2),
          _ToggleChip(
            label: 'Single',
            isSelected: viewMode == AccountViewMode.individual,
            onTap: () => onChanged(AccountViewMode.individual),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final onPrimary = isDark ? FinPilotColors.onPrimaryDark : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected && isDark
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? onPrimary
                : (isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
