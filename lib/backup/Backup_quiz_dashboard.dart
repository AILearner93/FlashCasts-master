import 'package:flutter/material.dart';
import 'package:quiz/models/completed_quiz.dart';

class QuizDashboard extends StatelessWidget {
  final List<CompletedQuiz> completedQuizzes;

  QuizDashboard({required this.completedQuizzes});

  List<CompletedQuiz> getLatestQuizzes() {
    // Sort by timestamp in descending order
    List<CompletedQuiz> sortedQuizzes = List.from(completedQuizzes)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Use a set to keep track of seen quiz names
    Set<String> seenQuizzes = Set();
    List<CompletedQuiz> latestQuizzes = [];

    for (var quiz in sortedQuizzes) {
      if (!seenQuizzes.contains(quiz.quizName)) {
        seenQuizzes.add(quiz.quizName);
        latestQuizzes.add(quiz);
      }
    }

    return latestQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    List<CompletedQuiz> latestQuizzes = getLatestQuizzes();

    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: latestQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = latestQuizzes[index];
          final wrongAnswers = quiz.totalQuestions - quiz.score;
          final percentageScore = (quiz.score / quiz.totalQuestions) * 100;

          return ListTile(
            title: Text(quiz.quizName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Questions: ${quiz.totalQuestions}'),
                Text('Correct Answers: ${quiz.score}'),
                Text('Wrong Answers: $wrongAnswers'),
                Text(
                    'Percentage Score: ${percentageScore.toStringAsFixed(2)}%'),
              ],
            ),
            trailing: Text('Score: ${quiz.score}/${quiz.totalQuestions}'),
          );
        },
      ),
    );
  }
}
