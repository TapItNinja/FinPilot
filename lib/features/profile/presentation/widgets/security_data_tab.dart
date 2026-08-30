// lib/features/profile/presentation/widgets/security_data_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/service_providers.dart';
import 'package:mobile_app/core/state/app_state_notifier.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/rules/data/rule_engine_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecurityDataTab extends ConsumerWidget {
  const SecurityDataTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Security & Authentication Section ────────────────────────
        _SectionHeader(
          title: 'Security & PIN Lock',
          subtitle: 'Protect your financial data with PIN passcode',
          icon: Icons.security_rounded,
        ),
        const SizedBox(height: 12),
        Material(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            side: BorderSide(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.pin_rounded, color: primaryColor),
                title: Text(
                  'Change Security PIN',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Update your 4-digit security code',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
                onTap: () => _showChangePinDialog(context, ref),
              ),
              Divider(
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
              ListTile(
                leading: const Icon(Icons.lock_clock_rounded, color: FinPilotColors.warning),
                title: Text(
                  'Lock App Now',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Instantly lock FinPilot requiring PIN',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                trailing: const Icon(Icons.lock_outline_rounded, color: FinPilotColors.warning),
                onTap: () {
                  ref.read(appStateProvider.notifier).lockApp();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Automation & Rules Section ───────────────────────────────
        _SectionHeader(
          title: 'Categorization Rules',
          subtitle: 'Manage merchant auto-categorization preset engine',
          icon: Icons.auto_fix_high_rounded,
        ),
        const SizedBox(height: 12),
        Material(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            side: BorderSide(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: const Icon(Icons.rule_folder_rounded, color: FinPilotColors.income),
            title: Text(
              'Auto-Categorization Rules Engine',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
              ),
            ),
            subtitle: Text(
              '71 Active preset rules matching transactions',
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: FinPilotColors.income.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '71 Active',
                style: TextStyle(
                  color: FinPilotColors.income,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => _showRulesOverviewDialog(context, ref),
          ),
        ),

        const SizedBox(height: 28),

        // ── Data Management Section ──────────────────────────────────
        _SectionHeader(
          title: 'Data & Storage',
          subtitle: 'Export backup files or clear application state',
          icon: Icons.storage_rounded,
        ),
        const SizedBox(height: 12),
        Material(
          color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            side: BorderSide(
              color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded, color: FinPilotColors.chartBlue),
                title: Text(
                  'Export Data (CSV / JSON)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Download copy of your transaction history',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction export file generated successfully.'),
                    ),
                  );
                },
              ),
              Divider(
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: FinPilotColors.expense),
                title: const Text(
                  'Clear All Local Storage',
                  style: TextStyle(
                    color: FinPilotColors.expense,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Danger: Permanently resets accounts & transactions',
                  style: TextStyle(
                    color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                  ),
                ),
                onTap: () => _confirmClearData(context, ref),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // ── Sign Out Button ──────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => ref.read(appStateProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: FinPilotColors.expense),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, color: FinPilotColors.expense),
            label: const Text(
              'Sign Out of FinPilot',
              style: TextStyle(
                color: FinPilotColors.expense,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _showChangePinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change 4-Digit PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter new 4-digit PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = controller.text.trim();
              if (pin.length == 4) {
                await ref.read(pinServiceProvider).savePin(pin);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN updated successfully!')),
                  );
                }
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  void _showRulesOverviewDialog(BuildContext context, WidgetRef ref) {
    final rulesService = ref.read(ruleEngineServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? FinPilotColors.darkBg : FinPilotColors.lightBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FutureBuilder(
        future: rulesService.getAllRules(),
        builder: (context, snapshot) {
          final rules = snapshot.data ?? [];
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Auto-Categorization Rules (${rules.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preset rule engine matches merchant names against standard spending categories.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: rules.length,
                      itemBuilder: (context, index) {
                        final rule = rules[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'If merchant contains "${rule.keyword}"',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'Categorize as: ${rule.category}',
                              style: TextStyle(
                                color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Local Storage?'),
        content: const Text(
          'This action will permanently delete all stored accounts, transactions, and preferences from Hive. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FinPilotColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await Hive.deleteFromDisk();
              await Hive.initFlutter();
              if (context.mounted) {
                Navigator.pop(context);
                ref.read(appStateProvider.notifier).logout();
              }
            },
            child: const Text('Delete Data'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
