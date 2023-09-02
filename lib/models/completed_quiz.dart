class CompletedQuiz {
  final String quizName;
  final int score;
  final int totalQuestions;
  final DateTime timestamp; // Add this line

  CompletedQuiz({
    required this.quizName,
    required this.score,
    required this.totalQuestions,
    required this.timestamp, // Add this line
  });
}
