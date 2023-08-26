import 'package:flutter/material.dart';
import 'package:quiz/models/completed_quiz.dart';
import 'package:quiz/widget/quiz_dashboard.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showDashboard = false;
  final List<CompletedQuiz> userCompletedQuizzes = [
    CompletedQuiz(quizName: "Math Quiz", score: 85),
    CompletedQuiz(quizName: "History Quiz", score: 78),
    // ... add more completed quizzes here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Logic to edit the profile can go here
            },
            child: Text('Edit Profile'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showDashboard = !_showDashboard;
              });
            },
            child: Text('Toggle Dashboard'),
          ),
          if (_showDashboard)
            Expanded(
                child: QuizDashboard(completedQuizzes: userCompletedQuizzes))
        ],
      ),
    );
  }
}
