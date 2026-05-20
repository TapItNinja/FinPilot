import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _storage= FlutterSecureStorage();
  static const _pinKey='user_pin';
  Future<void> savePin(String pin) async{
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async{
    return await _storage.read(key: _pinKey);
  }

  Future<bool> validatePin(String enteredPin) async{
    final savedPin= await getPin();
    return savedPin==enteredPin;
  }
}