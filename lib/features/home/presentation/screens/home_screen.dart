//lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/state/app_state_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('FinPilot')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(appStateProvider.notifier).logout();
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
