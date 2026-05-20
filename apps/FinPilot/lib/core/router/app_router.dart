import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/state/app_state_notifier.dart';
import 'package:mobile_app/features/shell/presentation/screens/app_shell.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../state/app_state.dart';

class AppRouter {
  static Widget getScreen(AppState state) {
    switch (state) {
      case AppState.initializing:
        return const SplashScreen();

      case AppState.unauthenticated:
        return const LoginScreen();

      case AppState.locked:
        return const LockScreen();

      case AppState.authenticated:
        return const AppShell();

      case AppState.onboarding:
        return const OnboardingScreen();

      case AppState.error:
        return const ErrorScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Splash Screen')));
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() {
    return _LockScreenState();
  }
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Enter PIN', style: TextStyle(fontSize: 24)),

              const SizedBox(height: 20),

              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  ref
                      .read(appStateProvider.notifier)
                      .unlockApp(_pinController.text);
                },
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(appStateProvider.notifier).finishOnboarding();
          },
          child: const Text('Finish Onboarding'),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Error Screen')));
  }
}
