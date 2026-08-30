// lib/features/accounts/data/datasources/account_local_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/account_entity.dart';

class AccountLocalDataSource {
  static const _boxName = 'accounts_box';
  Box? _box;

  Future<Box> get _openBox async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  Future<List<AccountEntity>> getAllAccounts() async {
    final box = await _openBox;
    final accounts = <AccountEntity>[];
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        accounts.add(AccountEntity.fromMap(Map<String, dynamic>.from(value)));
      }
    }
    accounts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return accounts;
  }

  Future<AccountEntity> saveAccount(AccountEntity account) async {
    final box = await _openBox;
    await box.put(account.id, account.toMap());
    return account;
  }

  Future<void> deleteAccount(String id) async {
    final box = await _openBox;
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _openBox;
    await box.clear();
  }
}
