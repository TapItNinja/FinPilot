// lib/features/statistics/domain/financial_health_calculator.dart
import '../../transactions/domain/entities/transaction_entity.dart';
import '../../budget/domain/budget_entity.dart';

class FinancialHealthMetric {
  final String title;
  final int score; // 0 to 100
  final String status;
  final String description;

  const FinancialHealthMetric({
    required this.title,
    required this.score,
    required this.status,
    required this.description,
  });
}

class FinancialHealthResult {
  final int overallScore; // 0 to 100
  final String tier; // e.g. "Excellent", "Good", "Fair", "Needs Attention"
  final String headline;
  final String primaryTip;
  final List<FinancialHealthMetric> breakdown;

  const FinancialHealthResult({
    required this.overallScore,
    required this.tier,
    required this.headline,
    required this.primaryTip,
    required this.breakdown,
  });

  static const empty = FinancialHealthResult(
    overallScore: 85,
    tier: 'Good',
    headline: 'Healthy Financial Baseline',
    primaryTip: 'Keep tracking your expenses and maintain a 20%+ savings rate.',
    breakdown: [],
  );
}

class FinancialHealthCalculator {
  static FinancialHealthResult calculate({
    required List<TransactionEntity> transactions,
    required List<BudgetStatus> budgets,
  }) {
    if (transactions.isEmpty) {
      return const FinancialHealthResult(
        overallScore: 80,
        tier: 'Good',
        headline: 'Financial Journey Started',
        primaryTip: 'Add your everyday transactions to generate in-depth health insights.',
        breakdown: [
          FinancialHealthMetric(
            title: 'Savings Rate',
            score: 80,
            status: 'Normal',
            description: 'Aim to save at least 20% of your total monthly income.',
          ),
          FinancialHealthMetric(
            title: 'Spending Discipline',
            score: 85,
            status: 'Good',
            description: 'No overspending detected in your active cycle.',
          ),
          FinancialHealthMetric(
            title: 'Cashflow Stability',
            score: 75,
            status: 'Normal',
            description: 'Maintain steady inflow and positive net cash reserves.',
          ),
        ],
      );
    }

    final debits = transactions.where((t) => t.type == TransactionType.debit).toList();
    final credits = transactions.where((t) => t.type == TransactionType.credit).toList();

    final totalSpent = debits.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = credits.fold<double>(0, (sum, t) => sum + t.amount);
    final net = totalIncome - totalSpent;

    // 1. Savings Rate Score (0 - 100)
    int savingsScore = 50;
    if (totalIncome > 0) {
      final savingsRate = (net / totalIncome).clamp(-1.0, 1.0);
      if (savingsRate >= 0.30) {
        savingsScore = 95;
      } else if (savingsRate >= 0.20) {
        savingsScore = 85;
      } else if (savingsRate >= 0.10) {
        savingsScore = 70;
      } else if (savingsRate >= 0.0) {
        savingsScore = 55;
      } else {
        savingsScore = 30;
      }
    } else if (totalSpent == 0) {
      savingsScore = 75;
    }

    // 2. Budget Adherence Score (0 - 100)
    int budgetScore = 80;
    if (budgets.isNotEmpty) {
      final overBudgets = budgets.where((b) => b.isOverBudget).length;
      if (overBudgets == 0) {
        budgetScore = 95;
      } else if (overBudgets == 1) {
        budgetScore = 65;
      } else {
        budgetScore = 40;
      }
    }

    // 3. Recurring Expense Burden (0 - 100)
    final recurringTotal = debits
        .where((t) => t.isRecurring)
        .fold<double>(0, (sum, t) => sum + t.amount);
    int recurringScore = 85;
    if (totalSpent > 0) {
      final recurringRatio = recurringTotal / totalSpent;
      if (recurringRatio > 0.60) {
        recurringScore = 50;
      } else if (recurringRatio > 0.40) {
        recurringScore = 70;
      } else {
        recurringScore = 90;
      }
    }

    // Overall Weighted Score
    final overall = ((savingsScore * 0.45) + (budgetScore * 0.35) + (recurringScore * 0.20)).round().clamp(10, 99);

    String tier;
    String headline;
    String primaryTip;

    if (overall >= 85) {
      tier = 'Excellent';
      headline = 'Outstanding Financial Health';
      primaryTip = 'Your savings rate and budget discipline are top-tier. Consider long-term index investments.';
    } else if (overall >= 70) {
      tier = 'Good';
      headline = 'Healthy & Balanced';
      primaryTip = 'You are consistently net positive. Trim minor lifestyle subscriptions to boost savings to 25%.';
    } else if (overall >= 50) {
      tier = 'Fair';
      headline = 'Room for Optimization';
      primaryTip = 'Expenses are running close to total income. Set category caps for Food and Shopping to build emergency reserves.';
    } else {
      tier = 'Needs Attention';
      headline = 'Deficit Detected';
      primaryTip = 'Outflows exceed current inflow. Freeze discretionary cards and stick to essential categories.';
    }

    return FinancialHealthResult(
      overallScore: overall,
      tier: tier,
      headline: headline,
      primaryTip: primaryTip,
      breakdown: [
        FinancialHealthMetric(
          title: 'Savings & Surplus Rate',
          score: savingsScore,
          status: savingsScore >= 80 ? 'Optimal' : (savingsScore >= 60 ? 'Healthy' : 'Low'),
          description: totalIncome > 0
              ? 'Saving ${(net > 0 ? (net / totalIncome * 100).toStringAsFixed(0) : '0')}% of monthly cashflow.'
              : 'Add income transactions to calculate precise surplus rate.',
        ),
        FinancialHealthMetric(
          title: 'Budget Discipline',
          score: budgetScore,
          status: budgetScore >= 80 ? 'On Track' : 'Near Limit',
          description: budgets.isNotEmpty
              ? '${budgets.where((b) => !b.isOverBudget).length} of ${budgets.length} budgets within spending caps.'
              : 'Budgets protect your cash reserves from impulse purchases.',
        ),
        FinancialHealthMetric(
          title: 'Fixed Obligation Ratio',
          score: recurringScore,
          status: recurringScore >= 80 ? 'Flexible' : 'High Fixed Costs',
          description: 'Recurring bills represent \$${recurringTotal.toStringAsFixed(0)} of total outlays.',
        ),
      ],
    );
  }
}
