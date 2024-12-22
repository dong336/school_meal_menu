class School {
  String id;
  String address;
  String schoolName;

  School({
    required this.id,
    required this.address,
    required this.schoolName,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      address: json['address'],
      schoolName: json['school_name'],
    );
  }
}