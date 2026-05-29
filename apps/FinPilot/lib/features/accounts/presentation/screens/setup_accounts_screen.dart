// lib/features/accounts/presentation/screens/setup_accounts_screen.dart
//
// Shown after PIN creation on first launch.
// User must add at least one account before entering the app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/state/app_state_notifier.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../providers/account_notifier.dart';
import '../widgets/account_card_widget.dart';
import 'add_account_flow.dart';

class SetupAccountsScreen extends ConsumerWidget {
  const SetupAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountNotifierProvider);

    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Setup your\naccounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add your bank accounts and credit cards to start tracking.',
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),

              const SizedBox(height: 32),

              // Existing accounts list
              accountsState.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, stackTrace) => Text('Error: $error'),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: accounts.map((account) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AccountCardWidget(account: account, height: 120),
                      );
                    }).toList(),
                  );
                },
              ),

              // Add account button
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const AddAccountFlow(isFirstSetup: true),
                    ),
                  );
                  // result = true means account was created
                  // Check if we should proceed to app
                  if (result == true) {
                    final accounts = await ref
                        .read(accountRepositoryProvider)
                        .getAllAccounts();
                    if (accounts.isNotEmpty && context.mounted) {
                      ref
                          .read(appStateProvider.notifier)
                          .accountsSetupComplete();
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FinPilotTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: FinPilotTheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FinPilotTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: FinPilotTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Account',
                        style: TextStyle(
                          color: FinPilotTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Continue button — only enabled after at least one account
              accountsState.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(appStateProvider.notifier)
                          .accountsSetupComplete(),
                      child: const Text('Continue to App'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
