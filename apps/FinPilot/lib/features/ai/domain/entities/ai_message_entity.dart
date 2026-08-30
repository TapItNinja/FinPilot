// lib/features/ai/domain/entities/ai_message_entity.dart
enum AiSender { user, assistant }

enum AiInsightType {
  spendingSummary,
  categoryBreakdown,
  budgetAlert,
  savingTip,
  merchantAnalysis,
}

class AiInsightPayload {
  final AiInsightType type;
  final String title;
  final String description;
  final double? primaryAmount;
  final String? metricLabel;
  final Map<String, double>? categoryBreakdown;
  final List<String>? suggestions;

  const AiInsightPayload({
    required this.type,
    required this.title,
    required this.description,
    this.primaryAmount,
    this.metricLabel,
    this.categoryBreakdown,
    this.suggestions,
  });
}

class AiMessage {
  final String id;
  final AiSender sender;
  final String text;
  final DateTime timestamp;
  final AiInsightPayload? insightPayload;

  const AiMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.insightPayload,
  });

  AiMessage copyWith({
    String? id,
    AiSender? sender,
    String? text,
    DateTime? timestamp,
    AiInsightPayload? insightPayload,
  }) {
    return AiMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      insightPayload: insightPayload ?? this.insightPayload,
    );
  }
}
