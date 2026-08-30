// lib/features/transactions/presentation/screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/spending_overview_card.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/stacked_card.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/summary_number.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/transaction_widget/transaction_app_bar.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';
import '../providers/transaction_notifier.dart';
import '../providers/transaction_summary_notifier.dart';
import '../widgets/transaction_widget/empty_transaction_state.dart';
import '../widgets/transaction_widget/error_transaction_state.dart';
import '../widgets/transaction_widget/grouped_transaction_sliver.dart';

// ── View mode toggle ──────────────────────────────────────────────────────────
enum AccountViewMode { overall, individual }

final accountViewModeProvider =
    NotifierProvider<_ViewModeNotifier, AccountViewMode>(_ViewModeNotifier.new);

class _ViewModeNotifier extends Notifier<AccountViewMode> {
  @override
  AccountViewMode build() => AccountViewMode.overall;

  void toggle(AccountViewMode mode) {
    state = mode;
  }
}

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen>
    with SingleTickerProviderStateMixin {
  int _currentCardIndex = 0;
  bool _isHistoryExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onModeChanged(AccountViewMode mode) {
    ref.read(accountViewModeProvider.notifier).toggle(mode);
    final activeAccounts = ref.read(activeAccountsProvider);

    if (mode == AccountViewMode.individual && activeAccounts.isNotEmpty) {
      // Pick whatever active card is currently on top of the stack!
      final targetIndex = (_currentCardIndex < activeAccounts.length) ? _currentCardIndex : 0;
      ref.read(selectedAccountProvider.notifier).select(activeAccounts[targetIndex]);
    } else {
      ref.read(selectedAccountProvider.notifier).select(null);
    }
  }

  void _onCardSwiped(int index) {
    _currentCardIndex = index;
    final viewMode = ref.read(accountViewModeProvider);
    final activeAccounts = ref.read(activeAccountsProvider);

    if (viewMode == AccountViewMode.individual && index < activeAccounts.length) {
      ref.read(selectedAccountProvider.notifier).select(activeAccounts[index]);
    }
  }

  void _toggleHistoryExpanded() {
    HapticFeedback.selectionClick();
    setState(() {
      _isHistoryExpanded = !_isHistoryExpanded;
      if (_isHistoryExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _collapseHistory() {
    if (_isHistoryExpanded) {
      HapticFeedback.selectionClick();
      setState(() {
        _isHistoryExpanded = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionNotifierProvider);
    final summary = ref.watch(transactionSummaryProvider);
    final grouped = ref.watch(groupedTransactionsProvider);
    final viewMode = ref.watch(accountViewModeProvider);
    final activeAccounts = ref.watch(activeAccountsProvider);
    final selectedAccount = ref.watch(selectedAccountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;

    final itemCount = transactionState.asData?.value.length ?? 0;

    // Auto-clamp active card index if accounts count changed
    if (activeAccounts.isNotEmpty && _currentCardIndex >= activeAccounts.length) {
      _currentCardIndex = activeAccounts.length - 1;
    }

    final filteredGrouped = <String, List<TransactionEntity>>{};
    for (final entry in grouped.entries) {
      final list = entry.value.where((t) {
        if (_filterType == 'Expenses' && t.type != TransactionType.debit) return false;
        if (_filterType == 'Income' && t.type != TransactionType.credit) return false;
        if (_filterType == 'Recurring' && !t.isRecurring) return false;
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          final mMatch = t.merchant.toLowerCase().contains(q);
          final cMatch = t.category.toLowerCase().contains(q);
          final nMatch = t.note?.toLowerCase().contains(q) ?? false;
          final aMatch = t.amount.toString().contains(q);
          if (!mMatch && !cMatch && !nMatch && !aMatch) return false;
        }
        return true;
      }).toList();

      if (list.isNotEmpty) {
        filteredGrouped[entry.key] = list;
      }
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
      onRefresh: () =>
          ref.read(transactionNotifierProvider.notifier).refreshTransactions(),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Pinned App Bar with Mode Switch ───────────────────────
            TransactionAppBar(
              viewMode: viewMode,
              ref: ref,
              onModeChanged: _onModeChanged,
            ),

            // ── Screen Content with Smooth Animation ──────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // ── View 1: Overview Dashboard (Fades & slides up slightly) ──
                      Opacity(
                        opacity: (1.0 - _expandAnimation.value).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, -20 * _expandAnimation.value),
                          child: IgnorePointer(
                            ignoring: _isHistoryExpanded,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Section 1: Hero Balance & Inflow/Outflow ──
                                  SummaryNumbers(summary: summary),

                                  const SizedBox(height: 14),

                                  // ── Section 2: Real-life 1.586:1 Credit Card Showcase ──
                                  StackedCards(
                                    accounts: activeAccounts,
                                    initialIndex: (_currentCardIndex < activeAccounts.length) ? _currentCardIndex : 0,
                                    onIndexChanged: _onCardSwiped,
                                  ),

                                  const SizedBox(height: 10),

                                  // ── Section 3: Filter Pill (Overall vs Filtered) ──
                                  Center(
                                    child: _FilterBadge(
                                      viewMode: viewMode,
                                      selectedAccount: selectedAccount,
                                      primaryColor: primaryColor,
                                      isDark: isDark,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // ── Section 4: Quick Spending Overview Insights ──
                                  SpendingOverviewCard(summary: summary),

                                  const SizedBox(height: 14),

                                  // ── Section 5: Transaction History Action Bar ──
                                  GestureDetector(
                                    onTap: _toggleHistoryExpanded,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? FinPilotColors.darkSurface
                                            : FinPilotColors.lightSurface,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark
                                              ? FinPilotColors.darkBorder
                                              : FinPilotColors.lightBorder,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Transaction History',
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(
                                                alpha: isDark ? 0.18 : 0.12,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: primaryColor.withValues(
                                                  alpha: isDark ? 0.3 : 0.25,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              '$itemCount items',
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? FinPilotColors.darkSurface2
                                                  : FinPilotColors.lightSurface2,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDark
                                                    ? FinPilotColors.darkBorder
                                                    : FinPilotColors.lightBorder,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.keyboard_arrow_up_rounded,
                                              size: 16,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── View 2: Full Expanded Transaction History (Slides in from bottom) ──
                      if (_expandAnimation.value > 0.01)
                        Positioned.fill(
                          child: Opacity(
                            opacity: _expandAnimation.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, 40 * (1.0 - _expandAnimation.value)),
                              child: IgnorePointer(
                                ignoring: !_isHistoryExpanded,
                                child: Container(
                                  color: isDark ? FinPilotColors.darkBg : FinPilotColors.lightBg,
                                  child: Column(
                                    children: [
                                      // Top Filter Badge
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                                        child: Center(
                                          child: _FilterBadge(
                                            viewMode: viewMode,
                                            selectedAccount: selectedAccount,
                                            primaryColor: primaryColor,
                                            isDark: isDark,
                                          ),
                                        ),
                                      ),

                                      // Pull down gesture / Collapse Header Bar
                                      GestureDetector(
                                        onVerticalDragEnd: (details) {
                                          if (details.primaryVelocity != null &&
                                              details.primaryVelocity! > 100) {
                                            _collapseHistory();
                                          }
                                        },
                                        onTap: _collapseHistory,
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Transaction History',
                                                style: TextStyle(
                                                  color: textPrimary,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withValues(
                                                    alpha: isDark ? 0.18 : 0.12,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '$itemCount items',
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              // Collapse Button
                                              IconButton(
                                                onPressed: _collapseHistory,
                                                icon: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? FinPilotColors.darkSurface2
                                                        : FinPilotColors.lightSurface2,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isDark
                                                          ? FinPilotColors.darkBorder
                                                          : FinPilotColors.lightBorder,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    color: textSecondary,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Search & Filter Bar
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.search_rounded, size: 18, color: textSecondary),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _searchController,
                                                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                                                        style: TextStyle(
                                                          color: textPrimary,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        decoration: InputDecoration(
                                                          hintText: 'Search merchant, category, note...',
                                                          hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                                                          border: InputBorder.none,
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ),
                                                    if (_searchQuery.isNotEmpty)
                                                      GestureDetector(
                                                        onTap: () {
                                                          _searchController.clear();
                                                          setState(() => _searchQuery = '');
                                                        },
                                                        child: Icon(Icons.close_rounded, size: 16, color: textSecondary),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Export CSV Action
                                            IconButton(
                                              tooltip: 'Export Transactions',
                                              style: IconButton.styleFrom(
                                                backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  side: BorderSide(color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
                                                ),
                                              ),
                                              icon: Icon(Icons.file_download_outlined, size: 18, color: primaryColor),
                                              onPressed: () {
                                                HapticFeedback.mediumImpact();
                                                final allFiltered = <dynamic>[];
                                                for (final l in filteredGrouped.values) {
                                                  allFiltered.addAll(l);
                                                }
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Exported ${allFiltered.length} transactions to CSV.'),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Filter Chips
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            _buildFilterChip('All', isDark, primaryColor, textPrimary, textSecondary),
                                            const SizedBox(width: 8),
                                            _buildFilterChip('Expenses', isDark, primaryColor, textPrimary, textSecondary),
                                            const SizedBox(width: 8),
                                            _buildFilterChip('Income', isDark, primaryColor, textPrimary, textSecondary),
                                            const SizedBox(width: 8),
                                            _buildFilterChip('Recurring', isDark, primaryColor, textPrimary, textSecondary),
                                          ],
                                        ),
                                      ),

                                      // Full Scrollable Transaction History
                                      Expanded(
                                        child: transactionState.when(
                                          loading: () => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          error: (error, _) => ErrorTransactionState(
                                            error: error.toString(),
                                          ),
                                          data: (_) {
                                            if (filteredGrouped.isEmpty) {
                                              if (_searchQuery.isNotEmpty || _filterType != 'All') {
                                                return Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(32),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.search_off_rounded,
                                                          size: 44,
                                                          color: isDark ? Colors.white24 : Colors.black26,
                                                        ),
                                                        const SizedBox(height: 12),
                                                        Text(
                                                          'No Matching Transactions',
                                                          style: TextStyle(
                                                            color: textPrimary,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                          'Try adjusting your search keywords or active filters.',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: textSecondary,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const EmptyTransactionState();
                                            }
                                            return CustomScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              slivers: [
                                                GroupedTransactionSliver(
                                                  grouped: filteredGrouped,
                                                  ref: ref,
                                                ),
                                                const SliverToBoxAdapter(
                                                  child: SizedBox(height: 80),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSelected = _filterType == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterType = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.15)
              : (isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryColor : textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Filter Badge ──────────────────────────────────────────────────────────────
class _FilterBadge extends StatelessWidget {
  final AccountViewMode viewMode;
  final dynamic selectedAccount;
  final Color primaryColor;
  final bool isDark;

  const _FilterBadge({
    required this.viewMode,
    required this.selectedAccount,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            viewMode == AccountViewMode.individual
                ? Icons.credit_card_rounded
                : Icons.layers_rounded,
            size: 13,
            color: primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            viewMode == AccountViewMode.individual
                ? (selectedAccount != null
                    ? 'Filtered to ${selectedAccount.name} (•••• ${selectedAccount.last4Digits})'
                    : 'Select an account')
                : 'Overall',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
