import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:school_meal_menu/dto/school.dart';
import 'package:school_meal_menu/enums/constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import 'package:school_meal_menu/util/date_util.dart';
import 'package:school_meal_menu/util/string_util.dart';
import 'package:school_meal_menu/dto/neis/neis_response.dart';

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
  bool _isLoading = true;
  bool _isNoMeal = false;
  late DateTime _selectedDay;
  late School _school;

  late List<MealInfo> _mealInfoForThisMonth;
  late List<String> _mealForToday;

  DateTime _focusedDay = DateTime.now();
  DateTime _firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _lastDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 1)
          .subtract(const Duration(days: 1));

  BannerAd? _banner;
  bool _loadingBanner = false;

  Future<void> _createBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );
    if (size == null) {
      return;
    }
    final BannerAd banner = BannerAd(
      size: size,
      request: const AdRequest(),
      adUnitId: Constants.bannerAdUnitId.alias,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _banner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  @override
  void initState() {
    super.initState();
    _school = widget.school;
    _selectedDay = _focusedDay;

    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    _banner?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingBanner) {
      _loadingBanner = true;
      _createBanner(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_school.schoolName} 식단'),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/comment',
                  arguments: _school,
                );
              },
              icon: const Icon(Icons.comment),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colors.white,
                  child: TableCalendar(
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: Colors.black),
                      weekNumberTextStyle: TextStyle(color: Colors.red),
                      weekendTextStyle: TextStyle(color: Colors.red),
                    ),
                    locale: 'ko_KR',
                    firstDay: DateTime(DateTime.now().year - 2,
                        DateTime.now().month, DateTime.now().day),
                    lastDay: DateTime(DateTime.now().year + 2,
                        DateTime.now().month, DateTime.now().day),
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
                      _firstDayOfMonth =
                          DateTime(focusedDay.year, focusedDay.month, 1);
                      _lastDayOfMonth =
                          DateTime(focusedDay.year, focusedDay.month + 1, 1)
                              .subtract(const Duration(days: 1));
                      print(_firstDayOfMonth);
                      print(_lastDayOfMonth);
                      _getMenuListByMonth();
                    },
                  ),
                ),
                const Divider(),
                Text(DateUtil.convertToView(_selectedDay)),
                Expanded(
                  child: _isNoMeal
                      ? const Text("식사가 없는 날이에요")
                      : ListView.builder(
                          itemCount: _mealForToday.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(_mealForToday[index]),
                          ),
                        ),
                ),
                if (_banner != null)
                  Container(
                    color: Colors.green,
                    width: _banner!.size.width.toDouble(),
                    height: _banner!.size.height.toDouble(),
                    child: AdWidget(ad: _banner!),
                  ),
              ],
            )),
    );
  }

  void selectDay(selectedDay, focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      print(_selectedDay);
      _setTodayMeal();
    });
  }

  void _setTodayMeal() {
    final clickedDate = DateUtil.convertToStrFromDate(_selectedDay);
    final mealToday = _mealInfoForThisMonth
        .where((item) => clickedDate == item.MLSV_YMD)
        .toList();

    if (mealToday.isEmpty) {
      setState(() {
        _isNoMeal = true;
      });
      return;
    } else {
      setState(() {
        _isNoMeal = false;
      });
    }

    setState(() {
      _mealForToday = StringUtil.extractMenuItems(mealToday.first.DDISH_NM);
    });
  }

  Future<void> _initData() async {
    await _getMenuListByMonth();
    _setTodayMeal();
  }

  Future<void> _getMenuListByMonth() async {
    Uri uri = Uri.parse('${Constants.neisDomain.alias}/hub/mealServiceDietInfo')
        .replace(queryParameters: {
      "Type": "json",
      "pIndex": "1",
      "pSize": "30",
      "ATPT_OFCDC_SC_CODE": _school.ATPT_OFCDC_SC_CODE,
      "SD_SCHUL_CODE": _school.SD_SCHUL_CODE,
      "KEY": Constants.neisKey.alias,
      "MLSV_FROM_YMD": DateUtil.convertToStrFromDate(_firstDayOfMonth),
      "MLSV_TO_YMD": DateUtil.convertToStrFromDate(_lastDayOfMonth),
      "MMEAL_SC_CODE": "2", // 1: 조식, 2: 중식, ?
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        final List rows = jsonResponse['mealServiceDietInfo'][1]['row'];

        setState(() {
          _mealInfoForThisMonth =
              rows.map((item) => MealInfo.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load data, statusCode: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('HTTP error occurred: $error');
    }
  }
}
