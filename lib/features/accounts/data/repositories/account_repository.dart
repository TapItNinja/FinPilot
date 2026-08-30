// lib/features/accounts/data/repositories/account_repository.dart
import '../datasources/account_local_datasource.dart';
import '../../domain/entities/account_entity.dart';

class AccountRepository {
  final AccountLocalDataSource dataSource;
  AccountRepository(this.dataSource);

  Future<List<AccountEntity>> getAllAccounts() => dataSource.getAllAccounts();

  Future<AccountEntity> addAccount({
    required String name,
    required AccountKind kind,
    required String last4Digits,
    required CardGradientTheme gradientTheme,
  }) {
    final now = DateTime.now();
    final account = AccountEntity(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      kind: kind,
      last4Digits: last4Digits,
      gradientTheme: gradientTheme,
      createdAt: now,
      updatedAt: now,
    );
    return dataSource.saveAccount(account);
  }

  Future<AccountEntity> updateAccount(AccountEntity account) =>
      dataSource.saveAccount(account.copyWith(updatedAt: DateTime.now()));

  Future<void> deleteAccount(String id) => dataSource.deleteAccount(id);
}
