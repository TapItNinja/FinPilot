// lib/features/statistics/presentation/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/budget_progress_card.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/cashflow_velocity_card.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/category_donut_chart.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/financial_health_card.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/period_toggle.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/spending_trend_chart.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/statistics_section_header.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/summary_row.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/top_merchants_chart.dart';
import '../providers/statistics_notifier.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statisticsPeriodProvider);
    final data = ref.watch(statisticsDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: isDark ? FinPilotColors.darkBg : FinPilotColors.lightBg,
            title: Text(
              'Statistics & Insights',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: textPrimary,
                fontSize: 20,
                letterSpacing: -0.4,
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
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  PeriodToggle(
                    selected: period,
                    onChanged: (p) => ref
                        .read(statisticsPeriodProvider.notifier)
                        .setPeriod(p),
                  ),
                  const SizedBox(height: 16),

                  // Inflow & Outflow Summary Row
                  SummaryRow(data: data),
                  const SizedBox(height: 14),

                  // Cashflow Burn-Rate Velocity Card
                  CashflowVelocityCard(data: data, period: period),
                  const SizedBox(height: 14),

                  // Financial Health Score & Fiduciary Diagnostic
                  const FinancialHealthCard(),
                  const SizedBox(height: 14),

                  // Monthly Budget Progress
                  BudgetProgress(data: data),
                  const SizedBox(height: 20),

                  // Spending Trend
                  const SectionHeader(
                    title: 'Spending Trend',
                    subtitle: 'Daily spend vs budget target',
                  ),
                  const SizedBox(height: 10),
                  SpendingTrendChart(data: data, period: period),
                  const SizedBox(height: 20),

                  // Category Breakdown with Interactive Drilldown
                  const SectionHeader(
                    title: 'By Category',
                    subtitle: 'Tap any category for transaction breakdown',
                  ),
                  const SizedBox(height: 10),
                  CategoryDonutChart(data: data, period: period),
                  const SizedBox(height: 20),

                  // Top Merchants with Interactive Drilldown
                  const SectionHeader(
                    title: 'Top Merchants',
                    subtitle: 'Tap any merchant for visit logs and average spend',
                  ),
                  const SizedBox(height: 10),
                  TopMerchantsChart(data: data, period: period),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}