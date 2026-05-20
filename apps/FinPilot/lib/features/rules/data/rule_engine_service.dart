// WHY THIS FILE EXISTS:
// RuleEngine is pure logic — it knows nothing about Hive or Riverpod.
// RuleEngineService is the bridge between the two.
//
// Responsibilities:
// 1. Open and manage the Hive box that stores TagRuleEntity objects
// 2. Seed preset rules on first launch
// 3. Provide CRUD operations (add, update, delete, toggle) for rules
// 4. Expose a method to run the RuleEngine against a transaction or list
//
// This follows the same pattern as TransactionLocalDataSource —
// a dedicated datasource class per feature, injected via Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../transactions/domain/entities/transaction_entity.dart';
import '../domain/tag_rule_entity.dart';
import 'rule_engine.dart';

class RuleEngineService {
  static const _boxName = 'rules_box';
  static const _presetsSeededKey = 'presets_seeded'; // flag key in Hive
  Box? _box;

  // Lazy box opener — same pattern as TransactionLocalDataSource.
  // Opens the box only when first needed, then reuses it.
  Future<Box> get _openBox async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  // Called once when the app starts (from AppStateNotifier.initializeApp).
  // Checks if we've already seeded presets — if not, writes them to Hive.
  //
  // We use a flag key '_presetsSeededKey' stored in the same box.
  // Without this check, we'd re-seed presets every app launch,
  // overwriting any edits the user made to preset rules.
  Future<void> seedPresetsIfNeeded() async {
    final box = await _openBox;
    final alreadySeeded = box.get(_presetsSeededKey) == true;
    if (alreadySeeded) return;

    final presets = TagRuleEntity.presets();
    for (final rule in presets) {
      await box.put(rule.id, rule.toMap());
    }

    // Mark as seeded so we never do this again.
    await box.put(_presetsSeededKey, true);
  }

  // Returns ALL rules (preset + user-created), sorted by priority descending.
  // The UI and RuleEngine both use this list.
  Future<List<TagRuleEntity>> getAllRules() async {
    final box = await _openBox;

    final rules = <TagRuleEntity>[];

    for (final key in box.keys) {
      // Skip the flag key — it's a bool, not a rule map.
      if (key == _presetsSeededKey) continue;

      final value = box.get(key);
      if (value is Map) {
        rules.add(TagRuleEntity.fromMap(Map<String, dynamic>.from(value)));
      }
    }

    // Sort: highest priority first, then alphabetically by keyword as tiebreaker.
    rules.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return a.keyword.compareTo(b.keyword);
    });

    return rules;
  }

  // Adds a new user-created rule.
  // We generate the ID from the current timestamp — simple, unique, no package needed.
  // User rules get priority 2 so they always override presets (priority 1).
  Future<TagRuleEntity> addRule({
    required String keyword,
    required String category,
    String? subcategory,
    bool exactMatch = false,
  }) async {
    final box = await _openBox;
    final now = DateTime.now();

    final rule = TagRuleEntity(
      id: now.millisecondsSinceEpoch.toString(), // unique timestamp-based ID
      keyword: keyword,
      category: category,
      subcategory: subcategory,
      exactMatch: exactMatch,
      priority: 2, // user rules override presets
      isActive: true,
      isPreset: false,
      createdAt: now,
      updatedAt: now,
    );

    await box.put(rule.id, rule.toMap());
    return rule;
  }

  // Updates an existing rule (user-created or preset).
  // We copyWith the changes and update the timestamp.
  Future<TagRuleEntity> updateRule(
    TagRuleEntity existingRule, {
    String? keyword,
    String? category,
    String? subcategory,
    bool? exactMatch,
    bool? isActive,
  }) async {
    final box = await _openBox;

    final updated = existingRule.copyWith(
      keyword: keyword,
      category: category,
      subcategory: subcategory,
      exactMatch: exactMatch,
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    await box.put(updated.id, updated.toMap());
    return updated;
  }

  // Deletes a rule by ID.
  // We allow deleting preset rules too — power users might want to clean up.
  // The seedPresetsIfNeeded flag prevents them from coming back on next launch.
  Future<void> deleteRule(String ruleId) async {
    final box = await _openBox;
    await box.delete(ruleId);
  }

  // Convenience toggle — flips isActive without needing to pass all fields.
  // Used by the rules list UI when the user taps a toggle switch.
  Future<TagRuleEntity> toggleRule(TagRuleEntity rule) async {
    return updateRule(rule, isActive: !rule.isActive);
  }

  // The main method that the import pipeline will call.
  // Loads all rules from Hive, then runs RuleEngine.applyToAll().
  //
  // WHY load rules inside this method:
  // The caller (e.g. TransactionRepository) doesn't need to know about
  // Hive or TagRuleEntity — it just passes transactions in and gets
  // tagged transactions back. Clean interface.
  Future<List<TransactionEntity>> applyRulesToAll(
    List<TransactionEntity> transactions,
  ) async {
    final rules = await getAllRules();
    final engine = RuleEngine();
    return engine.applyToAll(transactions, rules);
  }

  // Single-transaction version — used after manual entry.
  Future<TransactionEntity> applyRulesTo(TransactionEntity transaction) async {
    final rules = await getAllRules();
    final engine = RuleEngine();
    return engine.apply(transaction, rules);
  }

  // Checks if a transaction should trigger the EMI prompt.
  // Called from the import pipeline after rules are applied.
  Future<bool> isEmiCandidate(
    TransactionEntity transaction, {
    double threshold = 10000,
  }) async {
    final engine = RuleEngine();
    return engine.detectEmiCandidate(transaction, threshold: threshold);
  }
}

// Riverpod provider — makes RuleEngineService available anywhere in the app.
// Using Provider (not StateNotifierProvider) because RuleEngineService
// doesn't hold reactive state itself — it's a service with async methods.
// The UI layer will use its own StateNotifier/AsyncNotifier to hold the rule list.
final ruleEngineServiceProvider = Provider<RuleEngineService>((ref) {
  return RuleEngineService();
});
