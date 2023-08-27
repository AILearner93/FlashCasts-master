import 'package:flutter/material.dart';
import 'package:quiz/models/completed_quiz.dart'; // Make sure the import path matches your project structure

class QuizDashboard extends StatelessWidget {
  final List<CompletedQuiz> completedQuizzes;

  QuizDashboard({required this.completedQuizzes});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Adjust this value to change the height of the dashboard
      child: ListView.builder(
        itemCount: completedQuizzes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(completedQuizzes[index].quizName),
            trailing: Text('Score: ${completedQuizzes[index].score}'),
          );
        },
      ),
    );
  }
}
