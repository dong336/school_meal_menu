import 'package:intl/intl.dart';

class DateUtil {

  static String convertToStrFromDate(DateTime dateTime) {
    return DateFormat('yyyyMMdd').format(dateTime);
  }

  static String convertToView(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}