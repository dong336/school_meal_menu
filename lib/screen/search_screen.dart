import 'dart:convert' as convert;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_meal_menu/dto/school.dart';

import 'package:school_meal_menu/enums/constants.dart';
import 'package:school_meal_menu/util/search_checker.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchController searchController = SearchController();
  TextEditingController textEditingController = TextEditingController();
  String? inputText;
  List<School> schools = [];

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
      appBar: AppBar(title: const Text('나의 학교 찾기')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor(
              isFullScreen: false,
              searchController: searchController,
              viewOnChanged: (_) {
                fetchSearchSchools(searchController.text);
              },
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: searchController,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (query) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) =>
                      schools.map((School school) => ListTile(
                            title: Text(school.schoolName),
                            subtitle: Text(school.address),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/home',
                                arguments: school,
                              );
                            },
                          )),
            ),
          ),
          Image.asset('assets/icon/meal_small.png'),
          if (_banner != null)
            Container(
              color: Colors.green,
              width: _banner!.size.width.toDouble(),
              height: _banner!.size.height.toDouble(),
              child: AdWidget(ad: _banner!),
            ),
        ],
      ),
    );
  }

  void fetchSearchSchools(String? text) {
    if (text == null ||
        text.trim().isEmpty ||
        !RegExp(r'[\uAC00-\uD7A3]').hasMatch(text)) return;

    Uri uri = Uri.parse('${Constants.serverDomain.alias}/api/school/search')
        .replace(queryParameters: {
      "school_name": SearchChecker.removeNonKorean(text),
    });

    http.get(uri).then((response) {
      if (response.statusCode == 200) {
        List jsonData =
            convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
        schools = jsonData.map((data) => School.fromJson(data)).toList();
        // print('schools: $schools');
      } else {
        // print('Failed: ${response.statusCode}');
      }
    }).catchError((e) {
      print('Error: $e');
    });
  }
}
