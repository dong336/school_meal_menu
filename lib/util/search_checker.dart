class SearchChecker {

  static String removeNonKorean(String input) {
    // 정규식을 사용하여 한국어 완성형 글자만 남김
    return input.replaceAll(RegExp(r'[^\uAC00-\uD7AF]+'), '');
  }
}