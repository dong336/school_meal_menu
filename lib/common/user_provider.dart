import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _anonymousUserId;
  String? _authorization;

  String? get userId => _userId;
  String? get anonymousUserId => _anonymousUserId;
  String? get authorization => _authorization;

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');

    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString('userId', _userId!);
    }

    notifyListeners();
  }

  Future<void> loadAnonymousUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _anonymousUserId = prefs.getString('anonymousUserId');

    if (_anonymousUserId == null) {
      _anonymousUserId = "익명 ${Random().nextInt(9000) + 1000}";
      await prefs.setString('anonymousUserId', _anonymousUserId!);
    }

    notifyListeners();
  }
}