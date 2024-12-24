import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _displayUserId;

  String? get userId => _userId;
  String? get displayUserId => _displayUserId;

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');

    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString('userId', _userId!);
    }

    notifyListeners();
  }

  Future<void> loadDiplayUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _displayUserId = prefs.getString('displayUserId');

    if (_displayUserId == null) {
      _displayUserId = "익명 ${Random().nextInt(9000) + 1000}";
      await prefs.setString('displayUserId', _displayUserId!);
    }

    notifyListeners();
  }
}