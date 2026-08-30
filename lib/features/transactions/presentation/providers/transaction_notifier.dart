// WHY THIS FILE EXISTS:
// This file has two jobs:
// 1. Define all the Riverpod providers for the transaction feature
// 2. Define TransactionNotifier — the state manager for the transaction list
//
// WHAT CHANGED FROM THE PREVIOUS VERSION:
// TransactionRepository now needs RuleEngineService as a second argument.
// We added ruleEngineServiceProvider here and pass it into the repository.
// Nothing else in the app needs to change — the repository handles the rest.
//
// Think of this file as the "wiring diagram" for the transaction feature.
// All the pieces (datasource, repository, rule engine, notifier) are
// created here and connected together.
//lib/features/transactions/presentation/providers/transaction_notifier.dart
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../../rules/data/rule_engine_service.dart';

// Layer 1: DataSource provider
// Creates the Hive wrapper. No dependencies.
final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>(
  (ref) => TransactionLocalDataSource(),
);

// Layer 2: RuleEngineService provider
// Re-exported here so transaction_notifier.dart is self-contained.
// The actual provider is defined in rule_engine_service.dart —
// we just reference it here. This avoids circular imports.
//
// NOTE: We import ruleEngineServiceProvider from rule_engine_service.dart.
// It's defined there (not here) because it belongs to the rules feature.
// We just use it here to wire the repository.

// Layer 3: Repository provider
// Creates TransactionRepository with BOTH dependencies injected.
// ref.read vs ref.watch:
//   - ref.read: get the value once, don't rebuild when it changes
//   - ref.watch: rebuild this provider whenever the dependency changes
// We use ref.read here because the datasource and rule engine service
// are stable — they don't change after creation.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final localDataSource = ref.read(transactionLocalDataSourceProvider);
  final ruleEngineService = ref.read(ruleEngineServiceProvider);
  return TransactionRepository(localDataSource, ruleEngineService);
});

// Layer 4: The notifier provider
// AsyncNotifierProvider because we're dealing with async data (Hive + network).
// The UI watches this and gets AsyncValue<List<TransactionEntity>> —
// which is either AsyncLoading, AsyncError, or AsyncData.
final transactionNotifierProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionEntity>>(
      TransactionNotifier.new,
    );

class TransactionNotifier extends AsyncNotifier<List<TransactionEntity>> {
  // build() is called automatically when the provider is first read.
  // It's the "initial load" — equivalent to initState in a StatefulWidget.
  // Riverpod calls this once and caches the result.
  @override
  Future<List<TransactionEntity>> build() async {
    return ref.watch(transactionRepositoryProvider).getTransactions();
  }

  // Called when the user pulls to refresh or when a background refresh
  // needs to surface new data to the UI.
  Future<void> refreshTransactions() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionRepositoryProvider).getTransactions(),
    );
  }

  // Called after manual entry, PDF import, or email sync.
  // Takes raw transactions, runs the full import pipeline
  // (rule engine + dedup + merge + save), then updates UI state.
  Future<void> importTransactions(List<TransactionEntity> raw) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionRepositoryProvider).importTransactions(raw),
    );
  }

  // Called from the manual entry screen.
  // Returns true if we should show the EMI dialog, false otherwise.
  // We use this return value in the UI to conditionally show the EMI prompt.
  Future<bool> addTransaction(TransactionEntity transaction) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final (saved, isEmiCandidate) = await repo.addSingleTransaction(
        transaction,
      );

      // Update state by prepending the new transaction to the current list.
      // We don't reload from Hive — we already have the current list in state.
      // This is faster and avoids a full reload.
      final current = state.asData?.value ?? [];
      state = AsyncData([saved, ...current]);

      return isEmiCandidate;
    } catch (e, st) {
      debugPrint('addTransaction error: $e\n$st');
      return false;
    }
  }

  // Called when user confirms EMI details or edits a transaction manually.
  Future<void> updateTransaction(TransactionEntity updated) async {
    try {
      await ref.read(transactionRepositoryProvider).updateTransaction(updated);

      // Replace the updated transaction in current state without full reload.
      final current = state.asData?.value ?? [];
      state = AsyncData(
        current.map((t) => t.id == updated.id ? updated : t).toList(),
      );
    } catch (e, st) {
      debugPrint('updateTransaction error: $e\n$st');
    }
  }

  // Called when user deletes a transaction.
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(transactionId);

      final current = state.asData?.value ?? [];
      state = AsyncData(current.where((t) => t.id != transactionId).toList());
    } catch (e, st) {
      debugPrint('deleteTransaction error: $e\n$st');
    }
  }

  // Called after user adds/edits/deletes a rule in the rules management screen.
  // Re-tags all cached transactions with the updated rule set,
  // then refreshes the UI so the new categories are visible immediately.
  Future<void> reapplyRules() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionRepositoryProvider).reapplyRulesToCache(),
    );
  }
}
