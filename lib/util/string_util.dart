class StringUtil {

  static List<String> extractMenuItems(String mealDetails) {
    // 괄호 사이의 내용을 모두 제거하고 <br/> 기준으로 나누기
    String cleanText = mealDetails.replaceAll(RegExp(r'\(.*?\)'), '').replaceAll('*', '').trim();
    return cleanText.split('<br/>');
  }
}