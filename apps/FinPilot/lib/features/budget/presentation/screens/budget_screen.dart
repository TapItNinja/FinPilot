// lib/features/budget/presentation/screens/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/budget/presentation/widgets/add_budget_button.dart';
import 'package:mobile_app/features/budget/presentation/widgets/add_category_button.dart';
import 'package:mobile_app/features/budget/presentation/widgets/budget_input_sheet.dart';
import 'package:mobile_app/features/budget/presentation/widgets/budget_status_card.dart';
import 'package:mobile_app/features/budget/presentation/widgets/section_header.dart';
import 'package:mobile_app/features/profile/presentation/screens/profile_screen.dart';

import '../providers/budget_notifier.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  static const _categories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Utilities',
    'Health',
    'Finance',
    'Education',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final statuses = ref.watch(budgetStatusProvider);
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${monthNames[now.month]} Budget',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                child: Text(
                  'F',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: budgetState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) {
          final overallStatus = statuses
              .where((s) => s.budget.isOverall)
              .firstOrNull;
          final categoryStatuses = statuses
              .where((s) => !s.budget.isOverall)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Overall Budget ─────────────────────────────────────
              SectionHeader(
                title: 'Overall Monthly Budget',
                subtitle:
                    'Your total spending cap for ${monthNames[now.month]}',
              ),
              const SizedBox(height: 12),

              overallStatus != null
                  ? BudgetStatusCard(
                      status: overallStatus,
                      onEdit: () => _showBudgetDialog(
                        context,
                        ref,
                        title: 'Overall Budget',
                        current: overallStatus.budget.limitAmount,
                        onSave: (amount) => ref
                            .read(budgetNotifierProvider.notifier)
                            .setOverallBudget(amount),
                        onDelete: () => ref
                            .read(budgetNotifierProvider.notifier)
                            .deleteBudget(overallStatus.budget.key),
                      ),
                    )
                  : AddBudgetButton(
                      label: 'Set Overall Budget',
                      onTap: () => _showBudgetDialog(
                        context,
                        ref,
                        title: 'Overall Budget',
                        onSave: (amount) => ref
                            .read(budgetNotifierProvider.notifier)
                            .setOverallBudget(amount),
                      ),
                    ),

              const SizedBox(height: 28),

              // ── Category Budgets ───────────────────────────────────
              const SectionHeader(
                title: 'Category Budgets',
                subtitle: 'Optional limits per spending category',
              ),
              const SizedBox(height: 12),

              ...categoryStatuses.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BudgetStatusCard(
                    status: status,
                    onEdit: () => _showBudgetDialog(
                      context,
                      ref,
                      title: '${status.budget.category} Budget',
                      current: status.budget.limitAmount,
                      onSave: (amount) => ref
                          .read(budgetNotifierProvider.notifier)
                          .setCategoryBudget(status.budget.category!, amount),
                      onDelete: () => ref
                          .read(budgetNotifierProvider.notifier)
                          .deleteBudget(status.budget.key),
                    ),
                  ),
                ),
              ),

              ..._categories
                  .where(
                    (cat) =>
                        !categoryStatuses.any((s) => s.budget.category == cat),
                  )
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CategoryAddButton(
                        category: cat,
                        onTap: () => _showBudgetDialog(
                          context,
                          ref,
                          title: '$cat Budget',
                          onSave: (amount) => ref
                              .read(budgetNotifierProvider.notifier)
                              .setCategoryBudget(cat, amount),
                        ),
                      ),
                    ),
                  ),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  void _showBudgetDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    double? current,
    required void Function(double) onSave,
    VoidCallback? onDelete,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BudgetInputSheet(
        title: title,
        current: current,
        onSave: (amount) {
          onSave(amount);
          Navigator.of(context).pop();
        },
        onDelete: onDelete != null
            ? () {
                onDelete();
                Navigator.of(context).pop();
              }
            : null,
      ),
    );
  }
}
