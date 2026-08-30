// lib/features/import/presentation/widgets/review_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/import/data/pdf_parser_service.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';

class ReviewView extends ConsumerWidget {
  final PdfImportResult result;
  final Set<int> selectedIndices;
  final AccountEntity? selectedAccount;
  final ValueChanged<int> onToggle;
  final ValueChanged<AccountEntity> onAccountSelected;
  final VoidCallback onImport;

  const ReviewView({
    super.key,
    required this.result,
    required this.selectedIndices,
    required this.selectedAccount,
    required this.onToggle,
    required this.onAccountSelected,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(activeAccountsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final onPrimary = isDark ? FinPilotColors.onPrimaryDark : Colors.white;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    return Column(
      children: [
        // ── Header ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          color: surfaceColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.bankName,
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${result.transactions.length} transactions found  •  ${selectedIndices.length} selected',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (result.duplicateCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: FinPilotColors.warning.withValues(alpha: isDark ? 0.18 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: FinPilotColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '⚠️ ${result.duplicateCount} duplicates',
                        style: const TextStyle(
                          color: FinPilotColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Account picker
              Text(
                'Import into account:',
                style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: accounts.isEmpty
                    ? Text(
                        'No accounts found',
                        style: TextStyle(color: textMuted),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: accounts.length,
                        separatorBuilder: (item, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final isSelected = selectedAccount?.id == account.id;
                          return GestureDetector(
                            onTap: () => onAccountSelected(account),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.12)
                                    : (isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? primaryColor : borderColor,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    account.name,
                                    style: TextStyle(
                                      color: isSelected ? primaryColor : textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'XXXX ${account.last4Digits}',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // ── Transaction list ─────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: result.transactions.length,
            itemBuilder: (context, index) {
              final t = result.transactions[index];
              final isSelected = selectedIndices.contains(index);

              return GestureDetector(
                onTap: () => onToggle(index),
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.isDuplicateCandidate
                          ? FinPilotColors.warning.withValues(alpha: isDark ? 0.1 : 0.06)
                          : surfaceColor,
                      borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
                      border: Border.all(
                        color: t.isDuplicateCandidate
                            ? FinPilotColors.warning.withValues(alpha: 0.35)
                            : isSelected
                                ? primaryColor.withValues(alpha: 0.5)
                                : borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.black26),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: onPrimary,
                                  size: 14,
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        // Transaction details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      t.merchant,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${t.type == TransactionType.debit ? '-' : '+'}\$${t.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: t.type == TransactionType.debit
                                          ? FinPilotColors.expense
                                          : FinPilotColors.income,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${t.date.day}/${t.date.month}/${t.date.year}',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (t.isDuplicateCandidate)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: FinPilotColors.warning,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          t.duplicateReason ?? 'Possible duplicate',
                                          style: const TextStyle(
                                            color: FinPilotColors.warning,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Import button ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          color: surfaceColor,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selectedIndices.isEmpty ? null : onImport,
              child: Text(
                'Import ${selectedIndices.length} Transaction${selectedIndices.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
