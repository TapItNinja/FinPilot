// // WHAT CHANGED FROM THE PREVIOUS VERSION:
// // Added seedPresetsIfNeeded() call inside initializeApp().
// // This runs once on first launch and writes the 71 preset rules to Hive.
// // On subsequent launches the seed is skipped (flag is set in Hive).
// // Everything else is unchanged.
// //lib/core/state/app_state_notifier.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_app/features/rules/data/rule_engine_service.dart';
// import '../providers/service_providers.dart';
// import 'app_state.dart';

// class AppStateNotifier extends Notifier<AppState> {
//   @override
//   AppState build() {
//     return AppState.initializing;
//   }

//   Future<void> initializeApp() async {
//     final authService = ref.read(authServiceProvider);
//     final pinService = ref.read(pinServiceProvider);
//     final ruleEngineService = ref.read(ruleEngineServiceProvider);

//     // Seed preset rules on first launch.
//     // seedPresetsIfNeeded() checks an internal flag — safe to call every launch.
//     // If already seeded, it returns immediately without doing anything.
//     await ruleEngineService.seedPresetsIfNeeded();

//     // Save a default PIN for development.
//     // Remove before publishing — PIN should be set by user during onboarding.
//     await pinService.savePin('1234');

//     final token = await authService.getToken();

//     if (token != null) {
//       state = AppState.locked;
//     } else {
//       state = AppState.unauthenticated;
//     }
//   }

//   Future<void> login() async {
//     final authService = ref.read(authServiceProvider);
//     await authService.saveToken('dummy_token');
//     final hasCompletedOnboarding = await authService.hasCompletedOnboarding();
//     if (hasCompletedOnboarding) {
//       state = AppState.authenticated;
//     } else {
//       state = AppState.onboarding;
//     }
//   }

//   Future<void> logout() async {
//     final authService = ref.read(authServiceProvider);
//     await authService.clearToken();
//     state = AppState.unauthenticated;
//   }

//   Future<void> unlockApp(String enteredPin) async {
//     final pinService = ref.read(pinServiceProvider);
//     final isValid = await pinService.validatePin(enteredPin);
//     if (isValid) {
//       state = AppState.authenticated;
//     }
//   }

//   Future<void> finishOnboarding() async {
//     final authService = ref.read(authServiceProvider);
//     await authService.completeOnboarding();
//     state = AppState.authenticated;
//   }

//   void lockApp() {
//     state = AppState.locked;
//   }

//   void setErrorState() {
//     state = AppState.error;
//   }
// }

// final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
//   AppStateNotifier.new,
// );
// lib/core/state/app_state_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/rules/data/rule_engine_service.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import '../providers/service_providers.dart';
import 'app_state.dart';

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => AppState.initializing;

  Future<void> initializeApp() async {
    final authService = ref.read(authServiceProvider);
    final ruleEngineService = ref.read(ruleEngineServiceProvider);

    await ruleEngineService.seedPresetsIfNeeded();

    final token = await authService.getToken();

    if (token == null) {
      // No token → never logged in
      state = AppState.unauthenticated;
      return;
    }

    // Has token → check if PIN exists
    final pinService = ref.read(pinServiceProvider);
    final pin = await pinService.getPin();

    if (pin == null) {
      // Logged in but no PIN yet → onboarding (create PIN step)
      state = AppState.onboarding;
      return;
    }

    // Has PIN → check if any accounts exist
    final accountRepo = ref.read(accountRepositoryProvider);
    final accounts = await accountRepo.getAllAccounts();

    if (accounts.isEmpty) {
      // No accounts yet → setup accounts
      state = AppState.setupAccounts;
      return;
    }

    // Everything set up → show lock screen to enter PIN
    state = AppState.locked;
  }

  // Called after successful login from your Spring Boot backend.
  // token is the JWT returned by your API.
  Future<void> loginWithToken(String token) async {
    final authService = ref.read(authServiceProvider);
    await authService.saveToken(token);
    // After login, go to PIN creation (first time)
    state = AppState.onboarding;
  }

  // DEV ONLY — remove before publishing
  Future<void> devLogin() async {
    final authService = ref.read(authServiceProvider);
    await authService.saveToken('dummy_token');
    state = AppState.onboarding;
  }

  // Called after user sets their PIN on the create PIN screen
  Future<void> pinCreated(String pin) async {
    final pinService = ref.read(pinServiceProvider);
    await pinService.savePin(pin);

    // After PIN, check if accounts exist (edge case: user reinstalled app)
    final accountRepo = ref.read(accountRepositoryProvider);
    final accounts = await accountRepo.getAllAccounts();

    if (accounts.isEmpty) {
      state = AppState.setupAccounts;
    } else {
      state = AppState.authenticated;
    }
  }

  // Called after user adds their first account in setup
  Future<void> accountsSetupComplete() async {
    final authService = ref.read(authServiceProvider);
    await authService.completeOnboarding();
    state = AppState.authenticated;
  }

  // Called from lock screen after correct PIN entered
  Future<void> unlockApp(String enteredPin) async {
    final pinService = ref.read(pinServiceProvider);
    final isValid = await pinService.validatePin(enteredPin);
    if (isValid) {
      state = AppState.authenticated;
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.clearToken();
    state = AppState.unauthenticated;
  }

  void lockApp() => state = AppState.locked;

  void setErrorState() => state = AppState.error;
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);
