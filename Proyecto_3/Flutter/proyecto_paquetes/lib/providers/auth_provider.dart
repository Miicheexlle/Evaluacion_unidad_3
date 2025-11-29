import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  int? userId;
  String? role;
  String? fullName;

  bool get loggedIn => userId != null;

  void setUser({required int id, required String roleIn, required String full_name}) {
    userId = id;
    role = roleIn;
    fullName = full_name;
    notifyListeners();
  }

  void logout() {
    userId = null;
    role = null;
    fullName = null;
    notifyListeners();
  }
}
