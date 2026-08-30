// WHY THIS FILE EXISTS:
// The RuleEngine is the brain of auto-tagging.
// It takes a raw TransactionEntity and a list of TagRuleEntity rules,
// then returns a new TransactionEntity with category and autoTags filled in.
//
// It is a pure Dart class — no Flutter, no Hive, no Riverpod.
// This makes it very easy to unit test (we'll add tests before publishing).
//
// It does NOT fetch rules from Hive itself — the caller (RuleEngineService)
// is responsible for loading rules and passing them in.
// This separation means RuleEngine can be tested with a simple in-memory list.
//lib/features/rules/data/rule_engine.dart
import '../../transactions/domain/entities/transaction_entity.dart';
import '../domain/tag_rule_entity.dart';

class RuleEngine {
  // apply() is the main method.
  // It takes ONE transaction and a list of ALL active rules,
  // and returns the transaction with autoTags and category updated.
  //
  // We return a new TransactionEntity (using copyWith) because entities are immutable.
  // We never mutate the original.
  TransactionEntity apply(
    TransactionEntity transaction,
    List<TagRuleEntity> rules,
  ) {
    // Only process active rules.
    // Filter here (not at the storage layer) so we can pass all rules in
    // and let RuleEngine decide — keeps the caller simple.
    final activeRules = rules.where((r) => r.isActive).toList();

    if (activeRules.isEmpty) return transaction; // nothing to do

    // Find all rules that match this transaction's merchant name.
    final matchingRules = _findMatchingRules(transaction.merchant, activeRules);

    if (matchingRules.isEmpty) return transaction; // no rule matched

    // Sort by priority descending — highest priority rule wins for category.
    // We keep ALL matching rules for autoTags (union of all matched categories).
    matchingRules.sort((a, b) => b.priority.compareTo(a.priority));

    // The highest priority matching rule sets the category.
    // BUT only if the transaction's category is still 'Uncategorized' or empty.
    // We don't want to overwrite a category the user has already manually set.
    final topRule = matchingRules.first;
    final shouldUpdateCategory =
        transaction.category.isEmpty || transaction.category == 'Uncategorized';

    // Collect all unique categories from ALL matching rules for autoTags.
    // e.g. if 'uber eats' matches both 'uber' (Transport) and 'uber eats' (Food),
    // autoTags = ['Transport', 'Food'] and category = 'Food' (highest priority).
    final autoTags = matchingRules
        .map((r) => r.category)
        .toSet() // toSet removes duplicates
        .toList();

    return transaction.copyWith(
      category: shouldUpdateCategory ? topRule.category : transaction.category,
      // subcategory follows the same rule — only set if not already set.
      subcategory:
          (transaction.subcategory == null && topRule.subcategory != null)
          ? topRule.subcategory
          : transaction.subcategory,
      autoTags: autoTags,
    );
  }

  // applyToAll() is a convenience method for batch processing.
  // Used when importing a PDF statement or a batch of email transactions —
  // we process the whole list at once.
  //
  // Returns a new list — does not mutate the input list.
  List<TransactionEntity> applyToAll(
    List<TransactionEntity> transactions,
    List<TagRuleEntity> rules,
  ) {
    return transactions.map((t) => apply(t, rules)).toList();
  }

  // _findMatchingRules is private (underscore prefix = private in Dart).
  // It checks which rules match a given merchant name.
  //
  // All matching is case-insensitive — we lowercase both the merchant
  // and the keyword before comparing. This handles:
  //   'KFC', 'kfc', 'Kfc', 'KFC Indiranagar' — all match keyword 'kfc'.
  List<TagRuleEntity> _findMatchingRules(
    String merchant,
    List<TagRuleEntity> rules,
  ) {
    // Normalize: lowercase and trim whitespace.
    // Bank alert merchant names often have leading/trailing spaces.
    final normalizedMerchant = merchant.toLowerCase().trim();

    return rules.where((rule) {
      final normalizedKeyword = rule.keyword.toLowerCase().trim();

      if (rule.exactMatch) {
        // Exact match: merchant must equal keyword exactly (case-insensitive).
        return normalizedMerchant == normalizedKeyword;
      } else {
        // Contains match: merchant name must contain the keyword anywhere.
        // e.g. keyword 'amazon' matches 'Amazon Pay UPI', 'AMAZON.IN', etc.
        return normalizedMerchant.contains(normalizedKeyword);
      }
    }).toList();
  }

  // detectEmiCandidate() checks if a transaction looks like it could be an EMI.
  // Returns true if we should prompt the user "Was this converted to EMI?"
  //
  // Rules for EMI detection (conservative — better to miss one than annoy the user):
  // 1. Must be a debit (you don't pay EMI on credits)
  // 2. Amount must exceed the threshold (default ₹10,000)
  // 3. Must not already be marked as isEmi
  // 4. Must not be from a known small-ticket merchant (groceries, food, etc.)
  //
  // We keep this in RuleEngine because it's rule-based logic,
  // not persistence logic (that lives in the repository).
  bool detectEmiCandidate(
    TransactionEntity transaction, {
    double threshold = 10000,
  }) {
    if (transaction.type != TransactionType.debit) return false;
    if (transaction.isEmi) return false; // already flagged
    if (transaction.amount < threshold) return false;

    // Don't prompt for known small-ticket categories.
    // If autoTags already set 'Food' or 'Utilities', it's not an EMI.
    const nonEmiCategories = {'Food', 'Utilities', 'Transport', 'Health'};
    final hasNonEmiTag = (transaction.autoTags ?? []).any(
      (tag) => nonEmiCategories.contains(tag),
    );
    if (hasNonEmiTag) return false;

    return true; // looks like an EMI candidate — prompt the user
  }
}
