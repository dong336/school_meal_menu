class StringUtil {

  static List<String> extractMenuItems(String mealDetails) {
    // 괄호 사이의 내용을 모두 제거하고 <br/> 기준으로 나누기
    String cleanText = mealDetails.replaceAll(RegExp(r'\(.*?\)'), '').replaceAll('*', '').trim();
    // 특수문자 절사
    return cleanText
        .split('<br/>')
        .map((item) => item.replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z0-9\s]'), '').trim())
        .toList();
  }
}