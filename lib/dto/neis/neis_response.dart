class MealInfo {
  String ATPT_OFCDC_SC_CODE;
  String ATPT_OFCDC_SC_NM;
  String SD_SCHUL_CODE;
  String SCHUL_NM;
  String MMEAL_SC_CODE;
  String MMEAL_SC_NM;
  String MLSV_YMD;
  double MLSV_FGR;
  String DDISH_NM;
  String ORPLC_INFO;
  String CAL_INFO;
  String NTR_INFO;
  String MLSV_FROM_YMD;
  String MLSV_TO_YMD;
  String LOAD_DTM;

  MealInfo({
    required this.ATPT_OFCDC_SC_CODE,
    required this.ATPT_OFCDC_SC_NM,
    required this.SD_SCHUL_CODE,
    required this.SCHUL_NM,
    required this.MMEAL_SC_CODE,
    required this.MMEAL_SC_NM,
    required this.MLSV_YMD,
    required this.MLSV_FGR,
    required this.DDISH_NM,
    required this.ORPLC_INFO,
    required this.CAL_INFO,
    required this.NTR_INFO,
    required this.MLSV_FROM_YMD,
    required this.MLSV_TO_YMD,
    required this.LOAD_DTM,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      ATPT_OFCDC_SC_CODE: json['ATPT_OFCDC_SC_CODE'] ?? '',
      ATPT_OFCDC_SC_NM: json['ATPT_OFCDC_SC_NM'] ?? '',
      SD_SCHUL_CODE: json['SD_SCHUL_CODE'] ?? '',
      SCHUL_NM: json['SCHUL_NM'] ?? '',
      MMEAL_SC_CODE: json['MMEAL_SC_CODE'] ?? '',
      MMEAL_SC_NM: json['MMEAL_SC_NM'] ?? '',
      MLSV_YMD: json['MLSV_YMD'] ?? '',
      MLSV_FGR: (json['MLSV_FGR'] ?? 0.0).toDouble(),
      DDISH_NM: json['DDISH_NM'] ?? '',
      ORPLC_INFO: json['ORPLC_INFO'] ?? '',
      CAL_INFO: json['CAL_INFO'] ?? '',
      NTR_INFO: json['NTR_INFO'] ?? '',
      MLSV_FROM_YMD: json['MLSV_FROM_YMD'] ?? '',
      MLSV_TO_YMD: json['MLSV_TO_YMD'] ?? '',
      LOAD_DTM: json['LOAD_DTM'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ATPT_OFCDC_SC_CODE': ATPT_OFCDC_SC_CODE,
      'ATPT_OFCDC_SC_NM': ATPT_OFCDC_SC_NM,
      'SD_SCHUL_CODE': SD_SCHUL_CODE,
      'SCHUL_NM': SCHUL_NM,
      'MMEAL_SC_CODE': MMEAL_SC_CODE,
      'MMEAL_SC_NM': MMEAL_SC_NM,
      'MLSV_YMD': MLSV_YMD,
      'MLSV_FGR': MLSV_FGR,
      'DDISH_NM': DDISH_NM,
      'ORPLC_INFO': ORPLC_INFO,
      'CAL_INFO': CAL_INFO,
      'NTR_INFO': NTR_INFO,
      'MLSV_FROM_YMD': MLSV_FROM_YMD,
      'MLSV_TO_YMD': MLSV_TO_YMD,
      'LOAD_DTM': LOAD_DTM,
    };
  }
}
