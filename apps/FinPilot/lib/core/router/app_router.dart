// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/state/app_state_notifier.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/presentation/screens/setup_accounts_screen.dart';
import 'package:mobile_app/features/onboarding/presentation/screens/create_pin_screen.dart';
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
      case AppState.onboarding:
        return const CreatePinScreen();
      case AppState.setupAccounts:
        return const SetupAccountsScreen();
      case AppState.locked:
        return const LockScreen();
      case AppState.authenticated:
        return const AppShell();
      case AppState.error:
        return const ErrorScreen();
    }
  }
}

// ── Splash ────────────────────────────────────────────────────────────────────
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_rounded,
              color: FinPilotTheme.primary,
              size: 56,
            ),
            SizedBox(height: 16),
            Text(
              'FinPilot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lock Screen ───────────────────────────────────────────────────────────────
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final List<String> _pin = [];
  String? _errorMessage;

  void _onDigitTap(String digit) {
    setState(() {
      _errorMessage = null;
      if (_pin.length < 4) {
        _pin.add(digit);
        if (_pin.length == 4) {
          _tryUnlock();
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin.removeLast();
      }
      _errorMessage = null;
    });
  }

  Future<void> _tryUnlock() async {
    await ref.read(appStateProvider.notifier).unlockApp(_pin.join());
    // If still locked, PIN was wrong
    if (ref.read(appStateProvider) == AppState.locked && mounted) {
      setState(() {
        _errorMessage = 'Incorrect PIN';
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            children: [
              const Icon(
                Icons.lock_rounded,
                color: FinPilotTheme.primary,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? FinPilotTheme.primary
                          : FinPilotTheme.darkSurface2,
                      border: Border.all(
                        color: filled
                            ? FinPilotTheme.primary
                            : FinPilotTheme.darkBorder,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: FinPilotTheme.expense,
                    fontSize: 14,
                  ),
                ),
              ],

              const Spacer(),

              _NumberPad(onDigitTap: _onDigitTap, onDelete: _onDelete),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => ref.read(appStateProvider.notifier).logout(),
                child: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Number Pad (shared by lock + create PIN) ──────────────────────────────────
class _NumberPad extends StatelessWidget {
  final void Function(String digit) onDigitTap;
  final VoidCallback onDelete;

  const _NumberPad({required this.onDigitTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 80);
                }
                if (key == 'del') {
                  return _PadKey(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white70,
                      size: 22,
                    ),
                  );
                }
                return _PadKey(
                  child: Text(
                    key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => onDigitTap(key),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PadKey({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: FinPilotTheme.darkSurface,
          shape: BoxShape.circle,
          border: Border.all(color: FinPilotTheme.darkBorder),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Error Screen ──────────────────────────────────────────────────────────────
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      body: Center(
        child: Text(
          'Something went wrong',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
