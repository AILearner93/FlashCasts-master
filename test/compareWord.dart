import 'dart:math';

void main() {
  double jaroWinklerDistance(String s1, String s2) {
    final double threshold = 0.49;
    int matches = 0;
    int transpositions = 0;
    int maxLength = max(s1.length, s2.length);
    int prefixLength = 0;
    while (prefixLength < min(s1.length, s2.length) &&
        s1[prefixLength] == s2[prefixLength]) {
      prefixLength++;
      matches++;
    }
    s1 = s1.substring(matches);
    s2 = s2.substring(matches);
    for (int i = 0; i < s1.length; i++) {
      for (int j = max(0, i - 2); j < min(s2.length, i + 3); j++) {
        if (s1[i] == s2[j]) {
          matches++;
          if (j < i) transpositions++;
          break;
        }
      }
    }
    double similarity = matches / maxLength;
    return similarity > threshold
        ? similarity + (0.1 * prefixLength * (1 - similarity))
        : similarity;
  }

  List<Map<String, dynamic>> compareWords(List<String> words, String answer) {
    return words
        .map((word) => {
              'word': word,
              'distance': jaroWinklerDistance(word, answer),
              'passThreshold': jaroWinklerDistance(word, answer) >= 0.5,
            })
        .toList();
  }

  String compareAnswer(
      List<String> trueWords, List<String> falseWords, String answer) {
    double highestValueTrue = compareWords(trueWords, answer.substring(0, 2))
        .fold(0.0, (maxValue, r) => max(r['distance'], maxValue));
    double highestValueFalse = compareWords(falseWords, answer.substring(0, 2))
        .fold(0.0, (maxValue, r) => max(r['distance'], maxValue));

    if (highestValueFalse > highestValueTrue && highestValueFalse > 0.3)
      return "false";
    if (highestValueTrue > highestValueFalse && highestValueTrue > 0.3)
      return "true";
    return answer;
  }

//test code here
  List<String> trueWords = ['Tr', 'Tru'];
  List<String> falseWords = ['Fa', 'Fal'];
  String answer = 'Truest';

  String result = compareAnswer(trueWords, falseWords, answer);
  print(
      'Original Answer: $answer, Result: $result'); // Output should be "true" based on the provided logic
}
