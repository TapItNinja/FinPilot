// lib/features/transactions/data/repositories/transaction_repository.dart
import 'package:flutter/foundation.dart';
import '../datasources/transaction_local_datasource.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../rules/data/rule_engine_service.dart';

class TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final RuleEngineService ruleEngineService;

  TransactionRepository(this.localDataSource, this.ruleEngineService);

  Future<List<TransactionEntity>> getTransactions() async {
    final cached = await localDataSource.getCachedTransactions();
    if (cached.isNotEmpty) {
      _refreshInBackground();
      return cached;
    }
    // No dummy data — app starts empty, user adds via manual entry or PDF import
    return [];
  }

  Future<List<TransactionEntity>> importTransactions(
    List<TransactionEntity> rawTransactions,
  ) async {
    final tagged = await ruleEngineService.applyRulesToAll(rawTransactions);
    final existing = await localDataSource.getCachedTransactions();
    final existingIds = existing.map((t) => t.id).toSet();
    final newOnly = tagged.where((t) => !existingIds.contains(t.id)).toList();

    if (newOnly.isEmpty) {
      return existing;
    }

    final merged = [...existing, ...newOnly]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await localDataSource.cacheTransactions(merged);
    return merged;
  }

  Future<(TransactionEntity, bool)> addSingleTransaction(
    TransactionEntity raw,
  ) async {
    final tagged = await ruleEngineService.applyRulesTo(raw);
    final isEmi = await ruleEngineService.isEmiCandidate(tagged);
    final existing = await localDataSource.getCachedTransactions();
    await localDataSource.cacheTransactions([tagged, ...existing]);
    return (tagged, isEmi);
  }

  Future<void> updateTransaction(TransactionEntity updated) async {
    final existing = await localDataSource.getCachedTransactions();
    await localDataSource.cacheTransactions(
      existing.map((t) => t.id == updated.id ? updated : t).toList(),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final existing = await localDataSource.getCachedTransactions();
    await localDataSource.cacheTransactions(
      existing.where((t) => t.id != id).toList(),
    );
  }

  Future<List<TransactionEntity>> reapplyRulesToCache() async {
    final existing = await localDataSource.getCachedTransactions();
    if (existing.isEmpty) {
      return [];
    }
    final retagged = await ruleEngineService.applyRulesToAll(existing);
    await localDataSource.cacheTransactions(retagged);
    return retagged;
  }

  Future<void> _refreshInBackground() async {
    try {
      // No remote source yet — background refresh is a no-op until
      // Spring Boot backend is connected.
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }
}
