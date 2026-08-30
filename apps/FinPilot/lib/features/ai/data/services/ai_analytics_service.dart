// lib/features/ai/data/services/ai_analytics_service.dart
import 'package:mobile_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';

class AiAnalyticsService {
  AiMessage analyzeAndRespond(String query, List<TransactionEntity> transactions) {
    final lower = query.toLowerCase().trim();
    final now = DateTime.now();

    final expenses = transactions.where((t) => t.type == TransactionType.debit).toList();
    final income = transactions.where((t) => t.type == TransactionType.credit).toList();

    final totalSpent = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = income.fold<double>(0, (sum, t) => sum + t.amount);

    // ── 1. Biggest / Highest Expense Query ──────────────────────────────
    if (lower.contains('biggest') || lower.contains('highest') || lower.contains('largest') || lower.contains('top expense')) {
      if (expenses.isEmpty) {
        return AiMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          sender: AiSender.assistant,
          text: "You don't have any logged expenses yet. Tap **+** to add your first transaction or import a statement!",
          timestamp: DateTime.now(),
        );
      }

      expenses.sort((a, b) => b.amount.compareTo(a.amount));
      final top = expenses.first;

      return AiMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: AiSender.assistant,
        text: "Your single largest expense was **\$${top.amount.toStringAsFixed(2)}** at **${top.merchant}** under the **${top.category}** category.",
        timestamp: DateTime.now(),
        insightPayload: AiInsightPayload(
          type: AiInsightType.merchantAnalysis,
          title: 'Top Outflow: ${top.merchant}',
          description: 'Categorized under ${top.category}',
          primaryAmount: top.amount,
          metricLabel: 'Single Largest Charge',
          suggestions: [
            'How much did I spend in ${top.category}?',
            'Show my monthly spending',
          ],
        ),
      );
    }

    // ── 2. Category Breakdown / Specific Category Query ─────────────────
    final categories = ['food', 'dining', 'groceries', 'shopping', 'entertainment', 'bills', 'transport', 'health', 'travel', 'utilities'];
    final matchedCategory = categories.firstWhere(
      (c) => lower.contains(c),
      orElse: () => '',
    );

    if (matchedCategory.isNotEmpty || lower.contains('category') || lower.contains('breakdown') || lower.contains('where did my money go')) {
      final Map<String, double> categorySums = {};
      for (final tx in expenses) {
        final cat = tx.category.isEmpty ? 'Others' : tx.category;
        categorySums[cat] = (categorySums[cat] ?? 0) + tx.amount;
      }

      if (matchedCategory.isNotEmpty) {
        final specificSum = categorySums.entries
            .where((e) => e.key.toLowerCase().contains(matchedCategory))
            .fold<double>(0, (sum, e) => sum + e.value);

        return AiMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          sender: AiSender.assistant,
          text: specificSum > 0
              ? "You have spent a total of **\$${specificSum.toStringAsFixed(2)}** on **${matchedCategory.toUpperCase()}**."
              : "You have **\$0.00** recorded spending for **$matchedCategory** so far.",
          timestamp: DateTime.now(),
          insightPayload: AiInsightPayload(
            type: AiInsightType.categoryBreakdown,
            title: '${matchedCategory.toUpperCase()} Spend',
            description: 'Cumulative category outflow',
            primaryAmount: specificSum,
            metricLabel: 'Category Total',
            categoryBreakdown: categorySums,
            suggestions: ['What is my biggest expense?', 'How can I save money?'],
          ),
        );
      }

      // General category breakdown
      return AiMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: AiSender.assistant,
        text: categorySums.isNotEmpty
            ? "Here is your spending distribution across categories. Total debits recorded: **\$${totalSpent.toStringAsFixed(2)}**."
            : "No category transactions found to analyze.",
        timestamp: DateTime.now(),
        insightPayload: AiInsightPayload(
          type: AiInsightType.categoryBreakdown,
          title: 'Category Distribution',
          description: 'Breakdown of ${expenses.length} expense transactions',
          primaryAmount: totalSpent,
          metricLabel: 'Total Expenses',
          categoryBreakdown: categorySums,
          suggestions: ['Which merchant did I spend most at?', 'How is my budget?'],
        ),
      );
    }

    // ── 3. Total Spend / Balance / How much did I spend ─────────────────
    if (lower.contains('spend') || lower.contains('spent') || lower.contains('total') || lower.contains('balance') || lower.contains('income')) {
      final net = totalIncome - totalSpent;
      return AiMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: AiSender.assistant,
        text: "Summary of your finances:\n\n• **Total Inflow (Income):** \$${totalIncome.toStringAsFixed(2)}\n• **Total Outflow (Expenses):** \$${totalSpent.toStringAsFixed(2)}\n• **Net Balance:** \$${net.toStringAsFixed(2)}",
        timestamp: DateTime.now(),
        insightPayload: AiInsightPayload(
          type: AiInsightType.spendingSummary,
          title: 'Financial Summary',
          description: 'Cumulative inflow vs outflow balance',
          primaryAmount: net,
          metricLabel: 'Net Balance',
          suggestions: ['Show category breakdown', 'How can I save \$200?'],
        ),
      );
    }

    // ── 4. Savings Tips / How to save money ──────────────────────────────
    if (lower.contains('save') || lower.contains('saving') || lower.contains('tips') || lower.contains('advice')) {
      return AiMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: AiSender.assistant,
        text: "Here are 3 tailored financial recommendations based on your current cashflow:\n\n1. **The 50/30/20 Rule:** Direct 50% of your income to needs, 30% to wants, and 20% to savings.\n2. **Review Recurring Subscriptions:** Regularly audit monthly bank debits to cancel unused services.\n3. **Automate Weekly Deposits:** Schedule an automated transfer of \$50/week into a high-yield account.",
        timestamp: DateTime.now(),
        insightPayload: const AiInsightPayload(
          type: AiInsightType.savingTip,
          title: 'Smart Savings Blueprint',
          description: 'Target: Build 3-6 months emergency reserve',
          metricLabel: 'Recommended Rate',
          primaryAmount: 20.0,
          suggestions: ['What is my biggest expense?', 'Check my budget'],
        ),
      );
    }

    // ── 5. Budget Check / Health ─────────────────────────────────────────
    if (lower.contains('budget') || lower.contains('track') || lower.contains('afford')) {
      final burnRate = expenses.isEmpty ? 0.0 : totalSpent / (now.day);
      final projectedMonth = burnRate * 30;

      return AiMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: AiSender.assistant,
        text: "Your average daily spending velocity is **\$${burnRate.toStringAsFixed(2)}/day**.\n\nAt this pace, your projected monthly expense will be approximately **\$${projectedMonth.toStringAsFixed(2)}**.",
        timestamp: DateTime.now(),
        insightPayload: AiInsightPayload(
          type: AiInsightType.budgetAlert,
          title: 'Pacing & Burn Rate',
          description: 'Based on day ${now.day} of current billing cycle',
          primaryAmount: projectedMonth,
          metricLabel: 'Projected Month Outflow',
          suggestions: ['Show spending breakdown', 'Tips to save money'],
        ),
      );
    }

    // ── 6. Default Fallback ──────────────────────────────────────────────
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: AiSender.assistant,
      text: "I analyzed your financial records. You currently have **${transactions.length} total transactions** recorded with **\$${totalIncome.toStringAsFixed(2)}** in total income and **\$${totalSpent.toStringAsFixed(2)}** in total expenses.\n\nTry asking me:\n• *What is my biggest expense?*\n• *How much did I spend on Food?*\n• *Am I on track with my budget?*",
      timestamp: DateTime.now(),
      insightPayload: AiInsightPayload(
        type: AiInsightType.spendingSummary,
        title: 'FinPilot Intelligence',
        description: '${transactions.length} transactions in local vault',
        primaryAmount: totalSpent,
        metricLabel: 'Total Recorded Spend',
        suggestions: [
          'What is my biggest expense?',
          'How much did I spend on Food?',
          'How can I save money?',
        ],
      ),
    );
  }
}
