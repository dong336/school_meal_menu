import 'package:flutter/material.dart';
import 'package:school_meal_menu/dto/school_comment.dart';

class Comment extends StatefulWidget {
  final SchoolComment schoolComment;

  const Comment({
    super.key,
    required this.schoolComment,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  late SchoolComment _schoolComment;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
