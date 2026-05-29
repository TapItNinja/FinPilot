// lib/features/transactions/presentation/screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/stacked_card.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/summary_number.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/transaction_app_bar.dart';
import '../providers/transaction_notifier.dart';
import '../providers/transaction_summary_notifier.dart';
import '../widgets/transaction_widget/empty_transaction_state.dart';
import '../widgets/transaction_widget/error_transaction_state.dart';
import '../widgets/transaction_widget/transaction_section_header.dart';
import '../widgets/transaction_widget/grouped_transaction_sliver.dart';
import '../widgets/transaction_widget/account_carousel.dart';
import 'package:mobile_app/features/accounts/presentation/screens/add_account_flow.dart';

// ── View mode toggle ──────────────────────────────────────────────────────────
enum AccountViewMode { overall, individual }

final accountViewModeProvider =
    NotifierProvider<_ViewModeNotifier, AccountViewMode>(_ViewModeNotifier.new);

class _ViewModeNotifier extends Notifier<AccountViewMode> {
  @override
  AccountViewMode build() => AccountViewMode.overall;

  void toggle(AccountViewMode mode) {
    state = mode;
    // When switching to Overall, clear the account filter
    if (mode == AccountViewMode.overall) {
      ref.read(selectedAccountProvider.notifier).select(null);
    }
  }
}

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionNotifierProvider);
    final summary = ref.watch(transactionSummaryProvider);
    final grouped = ref.watch(groupedTransactionsProvider);
    final viewMode = ref.watch(accountViewModeProvider);
    final accounts = ref.watch(accountNotifierProvider).asData?.value ?? [];

    return RefreshIndicator(
      color: FinPilotTheme.primary,
      backgroundColor: FinPilotTheme.darkSurface,
      onRefresh: () =>
          ref.read(transactionNotifierProvider.notifier).refreshTransactions(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────
          TransactionAppBar(viewMode: viewMode, ref: ref),

          // ── Summary numbers ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SummaryNumbers(summary: summary),
            ),
          ),

          // ── Card section ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: viewMode == AccountViewMode.overall
                  ? StackedCards(accounts: accounts)
                  : AccountCarousel(
                      accounts: accounts,
                      onAddAccount: () => _openAddAccount(context, ref),
                    ),
            ),
          ),

          // ── Section header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: TransactionSectionHeader(transactionState: transactionState),
          ),

          // ── Transaction List ──────────────────────────────────────────
          transactionState.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              child: ErrorTransactionState(error: error.toString()),
            ),
            data: (_) {
              if (grouped.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyTransactionState(),
                );
              }
              return GroupedTransactionSliver(grouped: grouped, ref: ref);
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Future<void> _openAddAccount(BuildContext context, WidgetRef ref) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddAccountFlow()));
    await ref.read(accountNotifierProvider.notifier).refresh();
  }
}
