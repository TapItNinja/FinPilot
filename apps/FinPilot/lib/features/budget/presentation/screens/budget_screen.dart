// lib/features/budget/presentation/screens/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/budget/presentation/widgets/add_budget_button.dart';
import 'package:mobile_app/features/budget/presentation/widgets/add_category_button.dart';
import 'package:mobile_app/features/budget/presentation/widgets/budget_input_sheet.dart';
import 'package:mobile_app/features/budget/presentation/widgets/budget_status_card.dart';
import 'package:mobile_app/features/budget/presentation/widgets/section_header.dart';

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
      backgroundColor: FinPilotTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${monthNames[now.month]} Budget'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: budgetState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) {
          // Find existing budgets
          final overallStatus = statuses
              .where((s) => s.budget.isOverall)
              .firstOrNull;
          final categoryStatuses = statuses
              .where((s) => !s.budget.isOverall)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
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
              SectionHeader(
                title: 'Category Budgets',
                subtitle: 'Optional limits per spending category',
              ),
              const SizedBox(height: 12),

              // Show existing category budgets
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

              // Categories without budgets — show add buttons
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FinPilotTheme.darkSurface,
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



