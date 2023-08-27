import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/quiz.dart';
import 'package:quiz/widget/quiz_dashboard.dart';
import 'package:quiz/models/completed_quiz.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Sample user data
  String username = "John Doe";
  String userEmail = "johndoe@example.com";
  String userBio = "Just another Flutter enthusiast!";

  bool _showDashboard = false;
  final List<CompletedQuiz> userCompletedQuizzes = [
    CompletedQuiz(quizName: "Math Quiz", score: 85),
    CompletedQuiz(quizName: "History Quiz", score: 78),
    // ... add more completed quizzes here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * .025,
          horizontal: MediaQuery.of(context).size.width * .07,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: MediaQuery.of(context).size.width * .025),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/user_image.png'),
              ),
            ),
            SizedBox(height: 20),
            Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "Bio",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              userBio,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Edit profile logic
              },
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),  // <-- Added this SizedBox for spacing
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDashboard = !_showDashboard;
                });
              },
              child: Text('Toggle Dashboard'),
            ),
            if (_showDashboard) ...[
              QuizDashboard(completedQuizzes: userCompletedQuizzes)
            ],
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 35,
          height: 35,
        ),
        SizedBox(width: 24),
        Text(
          'Flashcast',
          style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        InkWell(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => Quiz()));
          },
          child: _navigationButton(context, 'Quiz'),
        ),
        SizedBox(width: 16),
        // No need to navigate to the same UserProfile page
        _navigationButton(context, 'User'),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _navigationButton(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
