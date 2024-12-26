import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_meal_menu/common/api_helper.dart';
import 'package:school_meal_menu/common/user_provider.dart';
import 'package:school_meal_menu/dto/school.dart';
import 'package:school_meal_menu/dto/school_comment.dart';
import 'package:school_meal_menu/enums/constants.dart';

class CommentScreen extends StatefulWidget {
  final School school;

  const CommentScreen({super.key, required this.school});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController textEditingController = TextEditingController();

  bool _isLoading = true;

  late School _school;
  late List<SchoolComment> _schoolComments;

  @override
  void initState() {
    super.initState();
    _school = widget.school;

    _initData();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final id = userProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_school.schoolName} 식단 게시판'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                    child: _schoolComments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icon/meal_small.png'),
                                const Text(
                                  '아직 작성된 글이 없네요.',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '첫 글을 작성해봐요.',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _schoolComments.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(_schoolComments[index].comment),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _schoolComments[index]
                                              .createdByAnonymous,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (id ==
                                            _schoolComments[index].createdBy)
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              _deleteComment(context,
                                                  _schoolComments[index].id);
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      _schoolComments[index].createdAt,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openInputDialog(context);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future _deleteComment(BuildContext context, int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _deleteProcess(context, id);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: const Text('예'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: const Text('아니오'),
          ),
        ],
      ),
    );
  }

  Future openInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 작성하기'),
        content: TextField(
          controller: textEditingController,
          maxLength: 500,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: '내용을 입력하세요.',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _addProcess(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: const Text('등록'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future _addProcess(BuildContext context) async {
    await _postComment(textEditingController.text);
    await _initData();
    Navigator.pop(context);
    textEditingController.clear();
  }

  Future _deleteProcess(BuildContext context, int id) async {
    await _calldDeleteMethod(id);
    await _initData();
    Navigator.pop(context);
  }

  Future<void> _postComment(String text) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final id = userProvider.userId;
    final anonymousId = userProvider.anonymousUserId;
    final headers = await ApiHelper.getHeaders();

    Uri uri =
        Uri.parse('${Constants.serverDomain.alias}/api/school-comment/basic');
    try {
      final Map<String, dynamic> requestBody = {
        "school_id": _school.id,
        "school_name": _school.schoolName,
        "comment": text,
        "created_by_anonymous": anonymousId,
        "created_by": id,
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: convert.jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        print('Response body: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('HTTP error occurred: $error');
    }
  }

  Future<void> _initData() async {
    Uri uri =
        Uri.parse('${Constants.serverDomain.alias}/api/school-comment/basic')
            .replace(queryParameters: {
      "school_id": _school.id.toString(),
    });

    final headers = await ApiHelper.getHeaders();

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List jsonResponse =
            convert.jsonDecode(convert.utf8.decode(response.bodyBytes));

        setState(() {
          _schoolComments =
              jsonResponse.map((data) => SchoolComment.fromJson(data)).toList();
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

  Future _calldDeleteMethod(int id) async {
    Uri uri =
        Uri.parse('${Constants.serverDomain.alias}/api/school-comment/basic');

    try {
      final Map<String, dynamic> requestBody = {"id": id};
      final headers = await ApiHelper.getHeaders();

      final response = await http.delete(
        uri,
        headers: headers,
        body: convert.jsonEncode(requestBody),
      );

      if (response.statusCode == 204) {
      } else {
        throw Exception(
            'Failed to load data, statusCode: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('HTTP error occurred: $error');
    }
  }
}
