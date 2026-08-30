// import 'app_state.dart';

// class AppStateController {
//   AppState _state = AppState.initializing;

//   AppState get state => _state;

//   void restoreSession() {
//     _state = AppState.authenticated;
//   }

//   void login() {
//     _state = AppState.authenticated;
//   }

//   void logout() {
//     _state = AppState.unauthenticated;
//   }

//   void lockApp() {
//     _state = AppState.locked;
//   }

//   void completeOnboarding() {
//     _state = AppState.authenticated;
//   }

//   void setErrorState() {
//     _state = AppState.error;
//   }
// }
//THIS IS THE OLD FILE AND WILL NOT BE USED -> NOW WE ARE USING APP_STATE_NOTIFIER FOR REACTIVE CHANGE AND USE RIVERPOD.