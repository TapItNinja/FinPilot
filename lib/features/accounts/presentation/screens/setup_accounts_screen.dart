// lib/features/accounts/presentation/screens/setup_accounts_screen.dart
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Setup your\naccounts',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Add your bank accounts and credit cards to start tracking.',
                style: TextStyle(color: textMuted, fontSize: 15),
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
                        child: AccountCardWidget(account: account),
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
                    color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                    borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add Account',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Continue button
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
                      child: const Text('Continue to App', style: TextStyle(fontWeight: FontWeight.w700)),
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
