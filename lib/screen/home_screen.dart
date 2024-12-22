import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:school_meal_menu/enums/constants.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      _getMenuList();

      print('clicked!');
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Future<void> _getMenuList() async {
    Uri url = Uri.parse('${Constants.serverUri.alias}/test');

    await http
        .get(url)
        .then((response) => print(response.body))
        .catchError((error) => print(error));
  }
}
