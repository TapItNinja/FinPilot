// lib/features/ai/presentation/widgets/ai_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:mobile_app/features/ai/presentation/widgets/ai_insight_card.dart';

class AiMessageBubble extends StatelessWidget {
  final AiMessage message;
  final ValueChanged<String>? onSuggestionTap;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.sender == AiSender.user;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2)
                        : (isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? primaryColor.withValues(alpha: isDark ? 0.3 : 0.4)
                          : (isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
                      width: 1.2,
                    ),
                  ),
                  child: _FormattedText(
                    text: message.text,
                    textColor: textPrimary,
                    isDark: isDark,
                  ),
                ),

                // Embedded Insight Card if available
                if (message.insightPayload != null)
                  AiInsightCard(
                    payload: message.insightPayload!,
                    onSuggestionTap: onSuggestionTap,
                  ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
              child: Text(
                'F',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Simple Markdown & Bullet Parser ───────────────────────────────────────────
class _FormattedText extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool isDark;

  const _FormattedText({
    required this.text,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.isEmpty) {
          return const SizedBox(height: 6);
        }

        // Bold formatting parser
        final spans = <TextSpan>[];
        final parts = line.split('**');

        for (int i = 0; i < parts.length; i++) {
          final isBold = i % 2 == 1;
          spans.add(
            TextSpan(
              text: parts[i],
              style: TextStyle(
                color: isBold ? primaryColor : textColor,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: RichText(text: TextSpan(children: spans)),
        );
      }).toList(),
    );
  }
}
