// lib/features/ai/data/datasources/ai_chat_local_datasource.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/features/ai/domain/entities/ai_message_entity.dart';

class AiChatLocalDatasource {
  static const String boxName = 'ai_chat_history_vault';
  static const String keyLastActivity = '__last_chat_activity__';
  static const String keyMessages = '__chat_messages_list__';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  /// Loads stored messages, automatically purging if inactive for > 30 days
  Future<List<AiMessage>> loadChatHistory() async {
    try {
      final box = await _getBox();
      final lastActivityStr = box.get(keyLastActivity) as String?;

      if (lastActivityStr != null) {
        final lastActivity = DateTime.tryParse(lastActivityStr);
        if (lastActivity != null) {
          final difference = DateTime.now().difference(lastActivity);
          // ── 30-day inactivity auto-purge rule ─────────────────────────
          if (difference.inDays >= 30) {
            await box.clear();
            return _defaultWelcomeMessages(isPostPurge: true);
          }
        }
      }

      final rawList = box.get(keyMessages) as List<dynamic>?;
      if (rawList == null || rawList.isEmpty) {
        return _defaultWelcomeMessages();
      }

      final messages = <AiMessage>[];
      for (final item in rawList) {
        if (item is String) {
          final map = jsonDecode(item) as Map<String, dynamic>;
          messages.add(_messageFromMap(map));
        } else if (item is Map) {
          messages.add(_messageFromMap(Map<String, dynamic>.from(item)));
        }
      }

      return messages.isNotEmpty ? messages : _defaultWelcomeMessages();
    } catch (e) {
      return _defaultWelcomeMessages();
    }
  }

  /// Saves the full chat history and updates the last activity timestamp
  Future<void> saveChatHistory(List<AiMessage> messages) async {
    try {
      final box = await _getBox();
      final serialized = messages.map((m) => jsonEncode(_messageToMap(m))).toList();

      await box.put(keyMessages, serialized);
      await box.put(keyLastActivity, DateTime.now().toIso8601String());
    } catch (_) {
      // Safe failover
    }
  }

  /// Clears the stored chat history
  Future<void> clearHistory() async {
    try {
      final box = await _getBox();
      await box.clear();
      await box.put(keyLastActivity, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  List<AiMessage> _defaultWelcomeMessages({bool isPostPurge = false}) {
    return [
      AiMessage(
        id: 'welcome_msg',
        sender: AiSender.assistant,
        text: isPostPurge
            ? "Hello Farida! 👋 Previous conversation older than 30 days of inactivity has been securely cleared.\n\nI am your **FinPilot AI Financial Advisor** powered by Gemini. Ask me anything about your spending, budgets, or financial plans!"
            : "Hello Farida! 👋 I am your **FinPilot AI Financial Advisor** powered by Gemini.\n\nI analyze your live transactions and bank accounts to give you instant financial advice, spending breakdowns, and savings strategies.",
        timestamp: DateTime.now(),
        insightPayload: const AiInsightPayload(
          type: AiInsightType.spendingSummary,
          title: 'Gemini Intelligence Online',
          description: 'Ready to query your transactions & budgets',
          suggestions: [
            'Where did my money go?',
            'What is my biggest expense?',
            'How much did I spend on Food?',
            'How can I save \$200?',
          ],
        ),
      ),
    ];
  }

  Map<String, dynamic> _messageToMap(AiMessage m) {
    return {
      'id': m.id,
      'sender': m.sender.name,
      'text': m.text,
      'timestamp': m.timestamp.toIso8601String(),
      'insightPayload': m.insightPayload != null
          ? {
              'type': m.insightPayload!.type.name,
              'title': m.insightPayload!.title,
              'description': m.insightPayload!.description,
              'primaryAmount': m.insightPayload!.primaryAmount,
              'metricLabel': m.insightPayload!.metricLabel,
              'categoryBreakdown': m.insightPayload!.categoryBreakdown,
              'suggestions': m.insightPayload!.suggestions,
            }
          : null,
    };
  }

  AiMessage _messageFromMap(Map<String, dynamic> map) {
    AiInsightPayload? payload;
    if (map['insightPayload'] != null) {
      final pMap = map['insightPayload'] as Map<String, dynamic>;
      final typeStr = pMap['type'] as String? ?? 'spendingSummary';
      final type = AiInsightType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => AiInsightType.spendingSummary,
      );

      Map<String, double>? categoryBreakdown;
      if (pMap['categoryBreakdown'] != null) {
        categoryBreakdown = (pMap['categoryBreakdown'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        );
      }

      List<String>? suggestions;
      if (pMap['suggestions'] != null) {
        suggestions = List<String>.from(pMap['suggestions']);
      }

      payload = AiInsightPayload(
        type: type,
        title: pMap['title'] ?? '',
        description: pMap['description'] ?? '',
        primaryAmount: (pMap['primaryAmount'] as num?)?.toDouble(),
        metricLabel: pMap['metricLabel'],
        categoryBreakdown: categoryBreakdown,
        suggestions: suggestions,
      );
    }

    final senderStr = map['sender'] as String? ?? 'assistant';
    final sender = senderStr == 'user' ? AiSender.user : AiSender.assistant;

    return AiMessage(
      id: map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      sender: sender,
      text: map['text'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      insightPayload: payload,
    );
  }
}
