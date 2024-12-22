import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:school_meal_menu/enums/constants.dart';
import 'package:school_meal_menu/util/search_checker.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchController searchController = SearchController();
  bool isDark = false;
  String? inputText;
  List? schools = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);
    // fetchSearchSchools('한국');
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('나의 학교 찾기')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                isFullScreen: false,
                searchController: searchController,
                viewOnChanged: (_) {
                  inputText = searchController.text;

                  fetchSearchSchools(inputText);
                },
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                    trailing: <Widget>[
                      Tooltip(
                        message: 'Change brightness mode',
                        child: IconButton(
                          isSelected: isDark,
                          onPressed: () {
                            setState(() {
                              isDark = !isDark;
                            });
                          },
                          icon: const Icon(Icons.wb_sunny_outlined),
                          selectedIcon: const Icon(Icons.brightness_2_outlined),
                        ),
                      )
                    ],
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(10, (int index) {
                    if (schools == null || schools!.isEmpty) return const ListTile();

                    return ListTile(
                      title: Text(schools![index]['school_name']),
                      onTap: () {},
                    );
                  });
                },
              ),
            ),
            Text('InputText: $inputText'),
          ],
        ),
      ),
    );
  }

  void fetchSearchSchools(String? text) {
    if (text == null || text.trim().isEmpty || !RegExp(r'[\uAC00-\uD7A3]').hasMatch(text)) return;

    Uri uri = Uri.parse('${Constants.serverUri.alias}/api/school/search')
        .replace(queryParameters: {
      "school_name": SearchChecker.removeNonKorean(text),
    });

    http.get(uri).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          schools = convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
        });
      } else {
        print('Failed: ${response.statusCode}');
      }
    }).catchError((e) {
      print('Error: $e');
    });
  }
}