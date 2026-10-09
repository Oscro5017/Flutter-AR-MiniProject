import 'package:flutter/material.dart';

enum UserRole { user, admin }

class UserProvider extends ChangeNotifier {
  UserRole _role = UserRole.user;
  String _userName = "User";
  String _userEmail = "user@example.com";

  UserRole get role => _role;
  bool get isAdmin => _role == UserRole.admin;
  String get userName => _userName;
  String get userEmail => _userEmail;

  void setRole(UserRole newRole) {
    if (_role != newRole) {
      _role = newRole;
      if (_role == UserRole.admin) {
        _userName = "System Admin";
        _userEmail = "admin@arfurniture.com";
      } else {
        _userName = "User";
        _userEmail = "user@example.com";
      }
      notifyListeners();
    }
  }

  void toggleRole() {
    setRole(_role == UserRole.user ? UserRole.admin : UserRole.user);
  }

  void login({required String name, required String email, required UserRole role}) {
    _userName = name;
    _userEmail = email;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _role = UserRole.user;
    _userName = "User";
    _userEmail = "user@example.com";
    notifyListeners();
  }
}
