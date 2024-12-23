class School {
  String id;
  String address;
  String schoolName;

  String ATPT_OFCDC_SC_CODE; // 시도교육청코드
  String SD_SCHUL_CODE; // 행정표준코드

  School({
    required this.id,
    required this.address,
    required this.schoolName,

    required this.ATPT_OFCDC_SC_CODE,
    required this.SD_SCHUL_CODE
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      address: json['address'],
      schoolName: json['school_name'],
      ATPT_OFCDC_SC_CODE: json['ATPT_OFCDC_SC_CODE'],
      SD_SCHUL_CODE: json['SD_SCHUL_CODE'],
    );
  }

  @override
  String toString() {
    return 'School(id: $id, schoolName: $schoolName, address: $address, ATPT_OFCDC_SC_CODE: $ATPT_OFCDC_SC_CODE, SD_SCHUL_CODE: $SD_SCHUL_CODE)';
  }
}