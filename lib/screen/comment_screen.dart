import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:school_meal_menu/component/comment.dart';
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
                    child: ListView.builder(
                  itemCount: _schoolComments.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(_schoolComments[index].comment),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _schoolComments[index].createdBy,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
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
          openInputDialog();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future openInputDialog() {
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
          TextButton(
            onPressed: () {
              _postComment(textEditingController.text);
              _initData();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey, width: 1),
            ),
            child: const Text('등록'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey, width: 1),
            ),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment(String text) async {
    Uri uri =
        Uri.parse('${Constants.serverDomain.alias}/api/school-comment/basic');
    try {
      final Map<String, dynamic> requestBody = {
        "school_id": _school.id,
        "school_name": _school.schoolName,
        "comment": text,
        "created_by": "system",
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json'
        },
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

    try {
      final response = await http.get(uri);
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
}
