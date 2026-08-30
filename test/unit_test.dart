// test/unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/state/app_state.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/budget/domain/budget_entity.dart';
import 'package:mobile_app/features/statistics/domain/financial_health_calculator.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_summary_notifier.dart';

void main() {
  group('AccountEntity Freeze Tests', () {
    test('default account is not frozen and can toggle freeze', () {
      final now = DateTime.now();
      final account = AccountEntity(
        id: 'acc_1',
        name: 'Chase Sapphire',
        kind: AccountKind.creditCard,
        last4Digits: '4242',
        gradientTheme: CardGradientTheme.tealBlue,
        createdAt: now,
        updatedAt: now,
      );

      expect(account.isFrozen, false);

      final frozen = account.copyWith(isFrozen: true);
      expect(frozen.isFrozen, true);

      final map = frozen.toMap();
      expect(map['isFrozen'], true);

      final restored = AccountEntity.fromMap(map);
      expect(restored.isFrozen, true);
      expect(restored.name, 'Chase Sapphire');
    });
  });

  group('FinancialHealthCalculator Tests', () {
    test('empty transactions returns baseline health score', () {
      final result = FinancialHealthCalculator.calculate(
        transactions: [],
        budgets: [],
      );

      expect(result.overallScore, 80);
      expect(result.tier, 'Good');
      expect(result.breakdown.length, 3);
    });

    test('high savings rate generates excellent score', () {
      final now = DateTime.now();
      final transactions = [
        TransactionEntity(
          id: 't1',
          amount: 5000,
          currencyCode: CurrencyCode.usd,
          merchant: 'Employer Salary',
          timestamp: now,
          category: 'Income',
          type: TransactionType.credit,
          source: 'manual',
          status: TransactionStatus.completed,
          isRecurring: true,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 't2',
          amount: 1200,
          currencyCode: CurrencyCode.usd,
          merchant: 'Whole Foods',
          timestamp: now,
          category: 'Food',
          type: TransactionType.debit,
          source: 'manual',
          status: TransactionStatus.completed,
          isRecurring: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = FinancialHealthCalculator.calculate(
        transactions: transactions,
        budgets: [
          BudgetStatus(
            budget: BudgetEntity.overall(limitAmount: 2000, month: now.month, year: now.year),
            spent: 1200,
          ),
        ],
      );

      expect(result.overallScore, greaterThanOrEqualTo(85));
      expect(result.tier, 'Excellent');
    });
  });

  group('TransactionSummary Tests', () {
    test('computes correct net and top category', () {
      final now = DateTime.now();
      final transactions = [
        TransactionEntity(
          id: 't1',
          amount: 3000,
          currencyCode: CurrencyCode.usd,
          merchant: 'Tech Consulting',
          timestamp: now,
          category: 'Income',
          type: TransactionType.credit,
          source: 'manual',
          status: TransactionStatus.completed,
          isRecurring: false,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 't2',
          amount: 450,
          currencyCode: CurrencyCode.usd,
          merchant: 'Trader Joe',
          timestamp: now,
          category: 'Food',
          type: TransactionType.debit,
          source: 'manual',
          status: TransactionStatus.completed,
          isRecurring: false,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 't3',
          amount: 150,
          currencyCode: CurrencyCode.usd,
          merchant: 'Uber',
          timestamp: now,
          category: 'Transport',
          type: TransactionType.debit,
          source: 'manual',
          status: TransactionStatus.completed,
          isRecurring: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = computeSummary(transactions);
      expect(summary.totalIncome, 3000);
      expect(summary.totalExpenses, 600);
      expect(summary.net, 2400);
      expect(summary.topCategory, 'Food');
      expect(summary.isPositive, true);
    });
  });

  group('AppState Tests', () {
    test('AppState enum contains walkthrough state', () {
      expect(AppState.values.contains(AppState.walkthrough), true);
    });
  });
}
