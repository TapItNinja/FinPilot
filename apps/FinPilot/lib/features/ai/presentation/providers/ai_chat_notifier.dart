// lib/features/ai/presentation/providers/ai_chat_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/ai/data/datasources/ai_chat_local_datasource.dart';
import 'package:mobile_app/features/ai/data/services/gemini_chat_service.dart';
import 'package:mobile_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_notifier.dart';

class AiChatState {
  final List<AiMessage> messages;
  final bool isTyping;

  const AiChatState({
    required this.messages,
    this.isTyping = false,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isTyping,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final aiChatLocalDatasourceProvider = Provider<AiChatLocalDatasource>((ref) {
  return AiChatLocalDatasource();
});

final geminiChatServiceProvider = Provider<GeminiChatService>((ref) {
  return GeminiChatService();
});

final aiChatNotifierProvider =
    NotifierProvider<AiChatNotifier, AiChatState>(AiChatNotifier.new);

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    _initChatHistory();
    return const AiChatState(messages: [], isTyping: false);
  }

  Future<void> _initChatHistory() async {
    final datasource = ref.read(aiChatLocalDatasourceProvider);
    final storedMessages = await datasource.loadChatHistory();
    state = state.copyWith(messages: storedMessages);
  }

  Future<void> sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    final userMessage = AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: AiSender.user,
      text: text,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];

    state = state.copyWith(
      messages: updatedMessages,
      isTyping: true,
    );

    final datasource = ref.read(aiChatLocalDatasourceProvider);
    await datasource.saveChatHistory(updatedMessages);

    final allTransactions = ref.read(transactionNotifierProvider).asData?.value ?? [];
    final allAccounts = ref.read(accountNotifierProvider).asData?.value ?? [];
    final activeAccounts = allAccounts.where((a) => !a.isFrozen).toList();
    final activeAccountIds = activeAccounts.map((a) => a.id).toSet();
    final activeTransactions = allTransactions.where((t) => activeAccountIds.contains(t.accountId)).toList();

    final geminiService = ref.read(geminiChatServiceProvider);

    final response = await geminiService.getAdvisorResponse(
      userQuery: text,
      transactions: activeTransactions,
      accounts: activeAccounts,
      conversationHistory: state.messages,
    );

    final finalMessages = [...state.messages, response];

    state = state.copyWith(
      messages: finalMessages,
      isTyping: false,
    );

    await datasource.saveChatHistory(finalMessages);
  }

  Future<void> clearChat() async {
    final datasource = ref.read(aiChatLocalDatasourceProvider);
    await datasource.clearHistory();
    final freshWelcome = await datasource.loadChatHistory();

    state = AiChatState(
      messages: freshWelcome,
      isTyping: false,
    );
  }
}
