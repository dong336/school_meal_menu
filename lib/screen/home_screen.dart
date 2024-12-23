import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:school_meal_menu/dto/school.dart';
import 'package:school_meal_menu/enums/constants.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final School school;

  const HomeScreen({
    super.key,
    required this.school,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool isLoading = true;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  late School _school;

  late DateTime _firstDayOfMonth;
  late DateTime _lastDayOfMonth;

  @override
  void initState() {
    super.initState();
    _school = widget.school;
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_school.schoolName} 식단')),
      body: SafeArea(
          child: Column(
        children: [
          TableCalendar(
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            locale: 'ko_KR',
            firstDay: DateTime(DateTime.now().year - 2, DateTime.now().month,
                DateTime.now().day),
            lastDay: DateTime(DateTime.now().year + 2, DateTime.now().month,
                DateTime.now().day),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              selectDay(selectedDay, focusedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
              _lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 1).subtract(const Duration(days: 1));
              print(_firstDayOfMonth);
              print(_lastDayOfMonth);
            },
          ),
          Column(
            children: [],
          ),
        ],
      )),
    );
  }

  void selectDay(selectedDay, focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      print(_selectedDay);
    });
  }

  Future<void> _getMenuListByMonth(DateTime dateTime) async {
    Uri uri = Uri.parse('${Constants.neisDomain.alias}/hub/mealServiceDietInfo')
        .replace(queryParameters: {
      "Type": "json",
      "pIndex": "1",
      "pSize": "30",
      "ATPT_OFCDC_SC_CODE": _school.ATPT_OFCDC_SC_CODE,
      "SD_SCHUL_CODE": _school.SD_SCHUL_CODE,
      "KEY": Constants.neisKey,
      "MLSV_FROM_YMD": "",
      "MLSV_TO_YMD": "",
    });

    await http
        .get(uri)
        .then((response) => print(response.body))
        .catchError((error) => print(error));
  }
}
