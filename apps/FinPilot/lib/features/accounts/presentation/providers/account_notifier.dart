// lib/features/accounts/presentation/providers/account_notifier.dart
//
// WHY THIS FILE EXISTS:
// AccountNotifier holds:
// 1. The list of all accounts
// 2. The currently selected account (null = Overall / all accounts)
//
// Every screen that needs to filter by account watches selectedAccountProvider.
// When null → show all transactions. When set → filter to that account's transactions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/account_local_datasource.dart';
import '../../data/repositories/account_repository.dart';
import '../../domain/entities/account_entity.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────
final accountLocalDataSourceProvider = Provider<AccountLocalDataSource>(
  (ref) => AccountLocalDataSource(),
);

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.read(accountLocalDataSourceProvider));
});

// ── Account list notifier ─────────────────────────────────────────────────────
final accountNotifierProvider =
    AsyncNotifierProvider<AccountNotifier, List<AccountEntity>>(
      AccountNotifier.new,
    );

class AccountNotifier extends AsyncNotifier<List<AccountEntity>> {
  @override
  Future<List<AccountEntity>> build() async {
    return ref.read(accountRepositoryProvider).getAllAccounts();
  }

  Future<AccountEntity> addAccount({
    required String name,
    required AccountKind kind,
    required String last4Digits,
    required CardGradientTheme gradientTheme,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    final account = await repo.addAccount(
      name: name,
      kind: kind,
      last4Digits: last4Digits,
      gradientTheme: gradientTheme,
    );
    final current = state.asData?.value ?? [];
    state = AsyncData([...current, account]);
    return account;
  }

  Future<void> deleteAccount(String id) async {
    await ref.read(accountRepositoryProvider).deleteAccount(id);
    final current = state.asData?.value ?? [];
    state = AsyncData(current.where((a) => a.id != id).toList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(accountRepositoryProvider).getAllAccounts(),
    );
  }
}

// ── Selected account provider ─────────────────────────────────────────────────
// null = Overall (all accounts combined)
// non-null = filter everything to this account
class SelectedAccountNotifier extends Notifier<AccountEntity?> {
  @override
  AccountEntity? build() => null; // default to Overall

  void select(AccountEntity? account) => state = account;
}

final selectedAccountProvider =
    NotifierProvider<SelectedAccountNotifier, AccountEntity?>(
      SelectedAccountNotifier.new,
    );
