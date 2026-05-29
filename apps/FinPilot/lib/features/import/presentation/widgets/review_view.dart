// ── Review view ───────────────────────────────────────────────────────────────
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
    final accounts = ref.watch(accountNotifierProvider).asData?.value ?? [];

    return Column(
      children: [
        // ── Header ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: FinPilotTheme.darkSurface,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${result.transactions.length} transactions found  •  ${selectedIndices.length} selected',
                        style: const TextStyle(
                          color: Colors.white38,
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
                        color: FinPilotTheme.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: FinPilotTheme.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '⚠️ ${result.duplicateCount} duplicates',
                        style: const TextStyle(
                          color: FinPilotTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Account picker
              const Text(
                'Import into account:',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: accounts.isEmpty
                    ? const Text(
                        'No accounts found',
                        style: TextStyle(color: Colors.white38),
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
                                    ? FinPilotTheme.primary.withValues(
                                        alpha: 0.2,
                                      )
                                    : FinPilotTheme.darkSurface2,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? FinPilotTheme.primary
                                      : FinPilotTheme.darkBorder,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    account.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? FinPilotTheme.primary
                                          : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'XXXX ${account.last4Digits}',
                                    style: const TextStyle(
                                      color: Colors.white38,
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
            padding: const EdgeInsets.all(12),
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
                          ? FinPilotTheme.warning.withValues(alpha: 0.06)
                          : FinPilotTheme.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: t.isDuplicateCandidate
                            ? FinPilotTheme.warning.withValues(alpha: 0.3)
                            : isSelected
                            ? FinPilotTheme.primary.withValues(alpha: 0.4)
                            : FinPilotTheme.darkBorder,
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
                            color: isSelected
                                ? FinPilotTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? FinPilotTheme.primary
                                  : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      t.merchant,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${t.type == TransactionType.debit ? '-' : '+'}₹${t.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: t.type == TransactionType.debit
                                          ? FinPilotTheme.expense
                                          : FinPilotTheme.income,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${t.date.day}/${t.date.month}/${t.date.year}',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (t.isDuplicateCandidate)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: FinPilotTheme.warning,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          t.duplicateReason ??
                                              'Possible duplicate',
                                          style: const TextStyle(
                                            color: FinPilotTheme.warning,
                                            fontSize: 11,
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          color: FinPilotTheme.darkBg,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selectedIndices.isEmpty ? null : onImport,
              child: Text(
                'Import ${selectedIndices.length} Transaction${selectedIndices.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
