import 'package:flutter/material.dart';
import 'package:quiz/models/completed_quiz.dart'; // Adjust the import based on your project name

class QuizDashboard extends StatelessWidget {
  final List<CompletedQuiz> completedQuizzes;

  QuizDashboard({required this.completedQuizzes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: completedQuizzes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(completedQuizzes[index].quizName),
          trailing: Text('Score: ${completedQuizzes[index].score}'),
        );
      },
    );
  }
}
