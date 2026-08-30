// lib/features/ai/presentation/widgets/ai_insight_card.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/ai/domain/entities/ai_message_entity.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsightPayload payload;
  final ValueChanged<String>? onSuggestionTap;

  const AiInsightCard({
    super.key,
    required this.payload,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final surfaceColor = isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(payload.type),
                  color: primaryColor,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payload.title,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      payload.description,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (payload.primaryAmount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '\$${payload.primaryAmount!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          // Optional Category Breakdown
          if (payload.categoryBreakdown != null && payload.categoryBreakdown!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 10),
            Column(
              children: payload.categoryBreakdown!.entries.take(4).map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${e.value.toStringAsFixed(2)}',
                        style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Suggestions
          if (payload.suggestions != null && payload.suggestions!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: payload.suggestions!.map((sug) {
                return GestureDetector(
                  onTap: () => onSuggestionTap?.call(sug),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 10, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          sug,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForType(AiInsightType type) {
    switch (type) {
      case AiInsightType.spendingSummary:
        return Icons.query_stats_rounded;
      case AiInsightType.categoryBreakdown:
        return Icons.donut_large_rounded;
      case AiInsightType.budgetAlert:
        return Icons.speed_rounded;
      case AiInsightType.savingTip:
        return Icons.lightbulb_rounded;
      case AiInsightType.merchantAnalysis:
        return Icons.storefront_rounded;
    }
  }
}
