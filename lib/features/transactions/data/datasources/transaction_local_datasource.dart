//lib/features/transactions/data/datasources/transaction_local_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionLocalDataSource {
  static const _boxName = 'transactions_box';
  Box? _box;

  Future<Box> get _openBox async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  Future<void> cacheTransactions(List<TransactionEntity> transactions) async {
    try {
      final box = await _openBox;

      // Overwrites entire list (not append)
      final transactionMaps = transactions.map((t) => t.toMap()).toList();
      await box.put('transactions', transactionMaps);
    } catch (e) {
      throw Exception('Failed to cache transactions: $e');
    }
  }

  Future<List<TransactionEntity>> getCachedTransactions() async {
    try {
      final box = await _openBox;
      final cachedData = box.get('transactions');

      if (cachedData == null) return [];

      final raw = List<dynamic>.from(cachedData);
      return raw.map((item) {
        return TransactionEntity.fromMap(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      throw Exception('Failed to retrieve cached transactions: $e');
    }
  }
}
