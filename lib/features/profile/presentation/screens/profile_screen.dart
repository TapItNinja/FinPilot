// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/profile/presentation/widgets/accessibility_tab.dart';
import 'package:mobile_app/features/profile/presentation/widgets/profile_tab.dart';
import 'package:mobile_app/features/profile/presentation/widgets/security_data_tab.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile & Settings'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                ),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                dividerHeight: 0.0,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight,
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: FinPilotColors.primaryDark.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                labelColor: isDark ? FinPilotColors.onPrimaryDark : Colors.white,
                unselectedLabelColor: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Options'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Security'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ProfileTab(),
            AccessibilityTab(),
            SecurityDataTab(),
          ],
        ),
      ),
    );
  }
}
