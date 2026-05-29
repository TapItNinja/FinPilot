//lib/features/transactions/presentation/widgets/add_transaction/toggle.dart
// ── Type Toggle ───────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';

class TypeToggle extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  const TypeToggle({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleOption(
            label: 'Debit',
            icon: Icons.arrow_upward_rounded,
            color: FinPilotTheme.expense,
            isSelected: selected == TransactionType.debit,
            onTap: () => onChanged(TransactionType.debit),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleOption(
            label: 'Credit',
            icon: Icons.arrow_downward_rounded,
            color: FinPilotTheme.income,
            isSelected: selected == TransactionType.credit,
            onTap: () => onChanged(TransactionType.credit),
          ),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : FinPilotTheme.darkSurface,
          border: Border.all(
            color: isSelected ? color : FinPilotTheme.darkBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
