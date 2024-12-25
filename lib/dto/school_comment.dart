class SchoolComment {
  int id;
  String comment;
  String createdByAnonymous;
  String createdBy;
  String createdAt;
  String? updatedAt;

  SchoolComment({
    required this.id,
    required this.comment,
    required this.createdByAnonymous,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory SchoolComment.fromJson(Map<String, dynamic> json) {
    return SchoolComment(
      id: json['id'],
      comment: json['comment'],
      createdByAnonymous: json['created_by_anonymous'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'created_by_anonymous': createdByAnonymous,
      'created_by': createdBy,
    };
  }
}