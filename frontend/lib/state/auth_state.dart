import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  bool _isGuest = true;
  bool get isGuest => _isGuest;

  void login() {
    _isGuest = false;
    notifyListeners();
  }

  void logout() {
    _isGuest = true;
    notifyListeners();
  }
}
