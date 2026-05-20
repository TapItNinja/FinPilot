import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/pin_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
//we are creating an instance of authProvider because we didnt wanted to create it in the 
//AppNotifier cause then it will be 1. tight coupling, hard testing, hidden dependencies.
final pinServiceProvider=Provider<PinService>((ref){
  return PinService();
});
