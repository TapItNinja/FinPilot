// lib/features/auth/presentation/screens/login_screen.dart
//
// DEV STUB — replace with real login UI when Spring Boot backend is ready.
// The actual API call will go in AppStateNotifier.loginWithToken(token).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import '../../../../core/state/app_state_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Logo + title
              const Icon(
                Icons.trending_up_rounded,
                color: FinPilotTheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to\nFinPilot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal finance tracker',
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),

              const Spacer(),

              // TODO: Replace with real email/password fields + Spring Boot API call
              // When backend is ready:
              // 1. Call POST /api/auth/login with email + password
              // 2. Get JWT token back
              // 3. Call ref.read(appStateProvider.notifier).loginWithToken(token)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(appStateProvider.notifier).devLogin(),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Continue (Dev Mode)'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(appStateProvider.notifier).devLogin(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: FinPilotTheme.darkBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.apple_rounded, color: Colors.white70),
                  label: const Text(
                    'Continue with Apple',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
