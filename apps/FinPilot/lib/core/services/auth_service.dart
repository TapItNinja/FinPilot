//lib/core/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//To access secure device storage library 
//this package stores sensitive data securely->1. auth token, refresh token, pin meta data, biometric.
//uses iOS key chain, Android keystore under the hood.
//we cant use sharedPreferences because that is plain local storage.

class AuthService {//creates dedicated auth persistence layer
//service layer is required because AppStateNotifier should'nt know how tokens are stored.
//Notifier only cares about session logic.
  static const _storage = FlutterSecureStorage();// static means it will be shared across all the instances.
  //will not be recreated each time.

  static const _tokenKey = 'auth_token';
  static const _onboardingKey = 'has_completed_onboarding';
//think of secure storage like a Map<String, String>. Your token is stored under the key "auth_token".
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  //this function will write/overwrite the token to encrypted storage. called after successful api response.

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  //this will fetch the token from the secure storage.

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
  //this will clear the token from the secure storage. eg. when we press logout.

  Future<void> completeOnboarding() async {
    await _storage.write(key: _onboardingKey, value: 'true');
  }

  Future<bool> hasCompletedOnboarding() async {
    final value=await _storage.read(key: _onboardingKey);
    return value=='true';
  }
}
//this dependency will be injected into the AppStateNotifier.
//this is called: "Separation of Concerns."