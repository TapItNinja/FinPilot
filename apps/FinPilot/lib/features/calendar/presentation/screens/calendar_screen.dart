//lib/features/calendar/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/calendar/presentation/widget/calender_grid.dart';
import 'package:mobile_app/features/calendar/presentation/widget/day_detail_panel.dart';
import 'package:mobile_app/features/calendar/presentation/widget/no_selection_hint.dart';
import '../providers/calendar_notifier.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final dayDetail = ref.watch(selectedDayDetailProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: FinPilotTheme.darkSurface,
            title: const Text('Calendar'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: FinPilotTheme.primary.withValues(alpha: 0.2),
                  child: const Text(
                    'P',
                    style: TextStyle(
                      color: FinPilotTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                      ? NoSelectionHint(key: const ValueKey('hint'))
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





