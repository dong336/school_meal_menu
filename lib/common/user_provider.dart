import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:school_meal_menu/dto/school.dart';
import 'package:school_meal_menu/screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _anonymousUserId;

  // shared_preferene 에 oject 저장이 안되므로 json 으로 바꿔 최근 검색 학교를 캐시
  String? _recentSchoolJson;

  String? get userId => _userId;

  String? get anonymousUserId => _anonymousUserId;

  String? get recentSchoolJson => _recentSchoolJson;

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

  Future<void> saveRecentSchool(School school) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _recentSchoolJson = jsonEncode(school);

    await prefs.setString('recentSchoolJson', _recentSchoolJson!);

    notifyListeners();
  }

  Future<void> loadRecentSchool(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _recentSchoolJson = prefs.getString('recentSchoolJson');

    try {
      if (_recentSchoolJson == null) return;

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => HomeScreen(
                  school: School.fromJson(jsonDecode(_recentSchoolJson!)))),
          ModalRoute.withName('/search'),
      );

      return;
    } catch (e) {
      throw Exception('error catch: $e');
    }
  }
}
