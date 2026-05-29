// lib/core/state/app_state.dart
enum AppState {
  initializing,
  unauthenticated, // not logged in → show login
  authenticated, // logged in, PIN unlocked, accounts set up → show app
  locked, // logged in but PIN not entered → show lock screen
  onboarding, // logged in, first time → create PIN
  setupAccounts, // PIN created, no accounts yet → setup accounts screen
  error,
}
