//lib/features/transactions/presentation/widgets/transaction_widget/transaction_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/transactions/presentation/screens/transaction_screen.dart';
// ── App Bar with toggle ───────────────────────────────────────────────────────
class TransactionAppBar extends StatelessWidget {
  final AccountViewMode viewMode;
  final WidgetRef ref;

  const TransactionAppBar({super.key, required this.viewMode, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: FinPilotTheme.darkBg,
      title: _ModeToggle(
        viewMode: viewMode,
        onChanged: (mode) =>
            ref.read(accountViewModeProvider.notifier).toggle(mode),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              // TODO: navigate to profile screen
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: FinPilotTheme.primary.withValues(alpha: 0.2),
              child: const Text(
                'P',
                style: TextStyle(
                  color: FinPilotTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: FinPilotTheme.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FinPilotTheme.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Overall',
            isSelected: viewMode == AccountViewMode.overall,
            onTap: () => onChanged(AccountViewMode.overall),
          ),
          const SizedBox(width: 2),
          _ToggleChip(
            label: 'Individual',
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? FinPilotTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
