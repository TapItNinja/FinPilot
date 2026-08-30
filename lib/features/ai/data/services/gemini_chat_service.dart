// lib/features/ai/data/services/gemini_chat_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/ai/data/services/ai_analytics_service.dart';
import 'package:mobile_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:mobile_app/features/transactions/domain/entities/transaction_entity.dart';

class GeminiChatService {
  final AiAnalyticsService _offlineFallbackService;
  final http.Client _httpClient;

  GeminiChatService({
    AiAnalyticsService? offlineFallbackService,
    http.Client? httpClient,
  })  : _offlineFallbackService = offlineFallbackService ?? AiAnalyticsService(),
        _httpClient = httpClient ?? http.Client();

  /// Primary query handler that leverages Gemini with offline analytics fallback
  Future<AiMessage> getAdvisorResponse({
    required String userQuery,
    required List<TransactionEntity> transactions,
    required List<AccountEntity> accounts,
    List<AiMessage> conversationHistory = const [],
  }) async {
    String apiKey = '';
    try {
      if (dotenv.isInitialized) {
        apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      }
    } catch (_) {
      apiKey = '';
    }
    if (apiKey.isEmpty) {
      apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    }

    // If no Gemini key is provided, execute local financial analysis
    if (apiKey.isEmpty) {
      return _offlineFallbackService.analyzeAndRespond(userQuery, transactions);
    }

    try {
      final financialContext = _buildFinancialContext(transactions, accounts);
      final systemPrompt = _buildSystemPrompt(financialContext);

      final contents = <Map<String, dynamic>>[];

      // System instruction as developer context
      contents.add({
        'role': 'user',
        'parts': [
          {'text': systemPrompt}
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Understood. I am FinPilot AI, ready to give personalized, precise financial advisory based on the provided records.'
          }
        ],
      });

      // Recent chat context (up to last 6 messages)
      for (final msg in conversationHistory.take(6)) {
        contents.add({
          'role': msg.sender == AiSender.user ? 'user' : 'model',
          'parts': [
            {'text': msg.text}
          ],
        });
      }

      // Current user query
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userQuery}
        ],
      });

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': contents,
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 800,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts.first['text'] as String? ?? '';
            if (text.isNotEmpty) {
              // Generate structured insight payload to accompany the Gemini response
              final offlineAnalysis = _offlineFallbackService.analyzeAndRespond(
                userQuery,
                transactions,
              );

              return AiMessage(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                sender: AiSender.assistant,
                text: text.trim(),
                timestamp: DateTime.now(),
                insightPayload: offlineAnalysis.insightPayload,
              );
            }
          }
        }
      }

      // If Gemini fails or returns error, use offline financial intelligence engine
      return _offlineFallbackService.analyzeAndRespond(userQuery, transactions);
    } catch (_) {
      // Graceful offline fallback
      return _offlineFallbackService.analyzeAndRespond(userQuery, transactions);
    }
  }

  String _buildSystemPrompt(String financialContext) {
    return '''
You are FinPilot AI, a fiduciary-grade, highly analytical, and charismatic personal financial advisor embedded in the FinPilot app.
You have real-time access to the user's financial records shown below.

YOUR GOAL:
1. Provide accurate, actionable, and encouraging financial guidance.
2. Directly answer user questions about their spending, budgets, balances, and savings goals using the provided financial data.
3. Structure responses with clean Markdown: use bold numbers for currency (e.g. **\$120.00**), bullet points for recommendations, and concise paragraphs.
4. If the user asks about affordability (e.g. "Can I buy a \$300 gadget?"), evaluate their cashflow, net balance, and monthly burn rate.

USER'S LIVE FINANCIAL RECORDS:
$financialContext
''';
  }

  String _buildFinancialContext(
    List<TransactionEntity> transactions,
    List<AccountEntity> accounts,
  ) {
    final expenses = transactions.where((t) => t.type == TransactionType.debit).toList();
    final income = transactions.where((t) => t.type == TransactionType.credit).toList();

    final totalSpent = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = income.fold<double>(0, (sum, t) => sum + t.amount);
    final net = totalIncome - totalSpent;

    final buffer = StringBuffer();
    buffer.writeln('• Total Accounts: ${accounts.length}');
    for (final acc in accounts) {
      buffer.writeln('  - ${acc.name} (${acc.kind == AccountKind.creditCard ? 'Credit Card' : 'Bank'}) [•••• ${acc.last4Digits}]');
    }

    buffer.writeln('• Total Income: \$${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('• Total Expenses: \$${totalSpent.toStringAsFixed(2)}');
    buffer.writeln('• Net Balance: \$${net.toStringAsFixed(2)}');
    buffer.writeln('• Total Transactions: ${transactions.length}');

    // Category distribution
    final Map<String, double> categorySums = {};
    for (final tx in expenses) {
      final cat = tx.category.isEmpty ? 'Others' : tx.category;
      categorySums[cat] = (categorySums[cat] ?? 0) + tx.amount;
    }
    buffer.writeln('• Category Spending Breakdown:');
    for (final entry in categorySums.entries) {
      buffer.writeln('  - ${entry.key}: \$${entry.value.toStringAsFixed(2)}');
    }

    // Recent 15 transactions
    buffer.writeln('• Recent Transactions:');
    for (final tx in transactions.take(15)) {
      final dateStr = '${tx.timestamp.year}-${tx.timestamp.month}-${tx.timestamp.day}';
      buffer.writeln('  - [$dateStr] ${tx.merchant}: \$${tx.amount.toStringAsFixed(2)} (${tx.type.name.toUpperCase()}, ${tx.category})');
    }

    return buffer.toString();
  }
}
