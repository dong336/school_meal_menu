import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiHelper {
  static Future<Map<String, String>> getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authorization = prefs.getString('Authorization');

    if (authorization == null) {
      await _loadAuthorization();
      authorization = prefs.getString('Authorization');
    }

    return {
      'Authorization': authorization!,
      'Content-Type': 'application/json',
    };
  }

  static Future<void> _loadAuthorization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authorization = prefs.getString('Authorization');

    if (authorization == null) {
      authorization = "Bearer KEY-${const Uuid().v4()}";
      await prefs.setString('Authorization', authorization);
    }
  }

  static Future<http.Response> get(String url) async {
    final headers = await getHeaders();
    return http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    return http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    return http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String url) async {
    final headers = await getHeaders();
    return http.delete(Uri.parse(url), headers: headers);
  }
}
