// lib/features/statistics/presentation/widgets/cashflow_velocity_card.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/statistics_notifier.dart';

class CashflowVelocityCard extends StatelessWidget {
  final StatisticsData data;
  final StatsPeriod period;

  const CashflowVelocityCard({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    final now = DateTime.now();
    final elapsedDays = period == StatsPeriod.week
        ? now.weekday
        : (period == StatsPeriod.month ? now.day : now.difference(DateTime(now.year, 1, 1)).inDays + 1);

    final burnRate = elapsedDays > 0 ? data.totalSpent / elapsedDays : 0.0;
    final totalPeriodDays = period == StatsPeriod.week
        ? 7
        : (period == StatsPeriod.month ? DateTime(now.year, now.month + 1, 0).day : 365);

    final projectedSpend = burnRate * totalPeriodDays;
    final isUnderBudget = data.budget > 0 ? projectedSpend <= data.budget : true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.speed_rounded, color: primaryColor, size: 15),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cashflow Burn-Rate',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isUnderBudget ? FinPilotColors.income : FinPilotColors.warning)
                      .withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUnderBudget ? 'On Pace' : 'High Velocity',
                  style: TextStyle(
                    color: isUnderBudget ? FinPilotColors.income : FinPilotColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Metrics 2-column row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY BURN RATE',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$${burnRate.toStringAsFixed(2)}/day',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROJECTED TOTAL',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$${projectedSpend.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isUnderBudget ? textPrimary : FinPilotColors.warning,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            'Based on $elapsedDays days of recorded transactions in this ${period.name}.',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
