import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  String? _userType;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get userType => _userType;

  void login(String username, String userType) {
    _username = username;
    _userType = userType;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _userType = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

