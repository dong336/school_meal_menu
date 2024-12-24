class SchoolComment {
  int id;
  String comment;
  String createdBy;
  String createdAt;
  String? updatedAt;

  SchoolComment({
    required this.id,
    required this.comment,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory SchoolComment.fromJson(Map<String, dynamic> json) {
    return SchoolComment(
      id: json['id'],
      comment: json['comment'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'created_by': createdBy,
    };
  }
}