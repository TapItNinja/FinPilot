// lib/features/profile/presentation/widgets/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/accounts/presentation/screens/add_account_flow.dart';
import 'package:mobile_app/features/onboarding/presentation/screens/app_walkthrough_screen.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_summary_notifier.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountNotifierProvider);
    final summary = ref.watch(transactionSummaryProvider);
    final accounts = accountsState.asData?.value ?? [];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── User Header Card ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: FinPilotColors.income,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Farida Orujova',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'farida.finance@finpilot.app',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FinPilot Pro Member',
                      style: TextStyle(
                        color: isDark ? primaryColor : primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Interactive App Tour Replay Card ─────────────────────────
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AppWalkthroughScreen(isStandalone: true),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
              borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
              border: Border.all(
                color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Replay App Walkthrough',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Review features, gestures & key hints',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Financial Snapshot Card ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                label: 'Total Net Balance',
                value: '\$${summary.net.toStringAsFixed(2)}',
                color: isDark ? FinPilotColors.primaryDark : FinPilotColors.income,
                icon: Icons.account_balance_wallet_rounded,
              ),
              Container(
                height: 40,
                width: 1,
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
              _MetricItem(
                label: 'Active Accounts',
                value: '${accounts.where((a) => !a.isFrozen).length}',
                color: FinPilotColors.chartBlue,
                icon: Icons.credit_card_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Accounts Section Header ───────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Connected Accounts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddAccountFlow()),
                );
                ref.read(accountNotifierProvider.notifier).refresh();
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text(
                'Add Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (accounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
              borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
              border: Border.all(
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
            ),
            child: Center(
              child: Text(
                'No accounts connected yet.',
                style: TextStyle(
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
              ),
            ),
          )
        else
          ...accounts.map(
            (acc) {
              final gradient = gradientForTheme(acc.gradientTheme);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                  borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
                  border: Border.all(
                    color: acc.isFrozen
                        ? Colors.blueAccent.withValues(alpha: isDark ? 0.35 : 0.3)
                        : (isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: acc.isFrozen
                            ? LinearGradient(
                                colors: [Colors.grey.shade700, Colors.grey.shade900],
                              )
                            : gradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first.withValues(alpha: acc.isFrozen ? 0.1 : 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          acc.last4Digits.isNotEmpty ? '••${acc.last4Digits}' : 'ACC',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  acc.name,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (acc.isFrozen) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withValues(alpha: isDark ? 0.2 : 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.ac_unit_rounded, color: Colors.blueAccent, size: 10),
                                      SizedBox(width: 3),
                                      Text(
                                        'FROZEN',
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${acc.kind.name.toUpperCase()} •••• ${acc.last4Digits}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (acc.isFrozen)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(accountNotifierProvider.notifier).toggleFreeze(acc.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${acc.name} unfrozen and restored to active stack!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.wb_sunny_rounded, size: 12),
                        label: const Text('Unfreeze', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      )
                    else
                      IconButton(
                        tooltip: 'Freeze Card',
                        icon: Icon(
                          Icons.ac_unit_rounded,
                          color: isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted,
                          size: 18,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.ac_unit_rounded, color: Colors.blueAccent, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Freeze Account?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              content: Text(
                                'Are you sure you want to freeze ${acc.name} (•••• ${acc.last4Digits})?\n\nThis will temporarily remove this card from your active stack and exclude its transactions from overall balances.',
                                style: TextStyle(
                                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Freeze Account', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref.read(accountNotifierProvider.notifier).toggleFreeze(acc.id);
                            final selected = ref.read(selectedAccountProvider);
                            if (selected?.id == acc.id) {
                              ref.read(selectedAccountProvider.notifier).select(null);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${acc.name} is now frozen.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
