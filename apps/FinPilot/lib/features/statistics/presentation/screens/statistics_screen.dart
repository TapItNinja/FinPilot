//lib/features/statistics/presentation/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/budget_progress_card.dart';
import 'package:mobile_app/features/statistics/presentation/widgets/category_donut_chart.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: FinPilotTheme.darkBg,
            title: const Text('Statistics'),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PeriodToggle(
                    selected: period,
                    onChanged: (p) => ref
                        .read(statisticsPeriodProvider.notifier)
                        .setPeriod(p),
                  ),
                  const SizedBox(height: 24),
                  SummaryRow(data: data),
                  const SizedBox(height: 24),
                  BudgetProgress(data: data),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Spending Trend',
                    subtitle: 'Daily spend vs budget target',
                  ),
                  const SizedBox(height: 12),
                  SpendingTrendChart(data: data, period: period),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'By Category',
                    subtitle: 'Where your money goes',
                  ),
                  const SizedBox(height: 12),
                  CategoryDonutChart(data: data),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Top Merchants',
                    subtitle: 'Highest spend this period',
                  ),
                  const SizedBox(height: 12),
                  TopMerchantsChart(data: data),
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