import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_app/features/rules/data/rule_engine_service.dart';
import '../providers/service_providers.dart';

import 'app_state.dart';

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    //initial state creator AppState.build(). like constructor.
    return AppState.initializing;
  }

  Future<void> login() async {
    // final ruleEngineService = ref.read(ruleEngineServiceProvider);
    // await ruleEngineService.seedPresetsIfNeeded();
    final authService = ref.read(authServiceProvider);
    await authService.saveToken('dummy_token');
    final hasCompletedOnboarding= await authService.hasCompletedOnboarding();
    if (hasCompletedOnboarding) {
      state = AppState.authenticated;
    } else {
      state = AppState.onboarding;
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.clearToken();
    state = AppState.unauthenticated;
  }

  Future<void> unlockApp(String enteredPin) async{
    final pinService=ref.read(pinServiceProvider);
    final isValid=await pinService.validatePin(enteredPin);
    if(isValid){
      state=AppState.authenticated;
    }
  }

  Future<void> finishOnboarding() async {
    final authService = ref.read(authServiceProvider);
    await authService.completeOnboarding();
    state = AppState.authenticated;
  }

  void lockApp() {
    state = AppState.locked;
  }

  void completeOnboarding() {
    state = AppState.authenticated;
  }

  void setErrorState() {
    state = AppState.error;
  }
  //TESTING THE INIT STATE. as it should only build once.
  // Future<void> initializeApp() async {
  //   await Future.delayed(const Duration(seconds: 2));

  //   final hasToken = false;

  //   if (hasToken) {
  //     state = AppState.locked;
  //   } else {
  //     state = AppState.unauthenticated;
  //   }
  // }
  Future<void> initializeApp() async {
    final authService = ref.read(
      authServiceProvider,
    ); //final means that variable can only be assigned once. BUT CAN BE MUTATED.(EDITABLE)

    final token = await authService.getToken();
    final pinService = ref.read(pinServiceProvider);
    await pinService.savePin('1234');

    if (token != null) {
      state = AppState.locked;
    } else {
      state = AppState.unauthenticated;
    }
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);
