// lib/features/calendar/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/calendar/presentation/widget/calender_grid.dart';
import 'package:mobile_app/features/calendar/presentation/widget/day_detail_panel.dart';
import 'package:mobile_app/features/calendar/presentation/widget/no_selection_hint.dart';
import 'package:mobile_app/features/profile/presentation/screens/profile_screen.dart';
import '../providers/calendar_notifier.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final dayDetail = ref.watch(selectedDayDetailProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Pinned App Bar ───────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: isDark ? FinPilotColors.darkBg : FinPilotColors.lightBg,
            title: Text(
              'Calendar',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Month Grid ───────────────────────────────────────
                CalendarGrid(calendarState: calendarState),

                // ── Day Detail Panel ─────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: dayDetail == null
                      ? const NoSelectionHint(key: ValueKey('hint'))
                      : DayDetailPanel(
                          key: ValueKey(calendarState.selectedDate),
                          detail: dayDetail,
                          ref: ref,
                        ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
