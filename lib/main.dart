import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:school_meal_menu/screen/comment_screen.dart';
import 'package:school_meal_menu/screen/search_screen.dart';
import 'package:school_meal_menu/common/user_provider.dart';
import 'package:school_meal_menu/screen/home_screen.dart';
import 'package:school_meal_menu/dto/school.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  MobileAds.instance.initialize();

  initializeDateFormatting().then((_) => {
        runApp(ChangeNotifierProvider(
          create: (context) => UserProvider(),
          child: const MyApp(),
        ))
      });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘의 학교 급식',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orangeAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          /*
             TODO shared_preferences 를 검사하여
             캐시된 학교 정보가 있다면 가장 최신 검색 이력에 대한 HomeScreen
             캐시된 학교 정보가 없으면 SearchSreen
          */
          return const SearchScreen();
        },
        '/search': (context) => const SearchScreen(),
        '/home': (context) => HomeScreen(
            school: ModalRoute.of(context)!.settings.arguments as School),
        '/comment': (context) => CommentScreen(
            school: ModalRoute.of(context)!.settings.arguments as School),
      },
    );
  }
}
