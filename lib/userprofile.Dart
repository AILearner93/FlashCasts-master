import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/quiz.dart';
import 'package:quiz/widget/quiz_dashboard.dart';
import 'package:quiz/models/completed_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Sample user data
  String username = "John Doe";
  String userEmail = "johndoe@example.com";
  String userBio = "Just another Flutter enthusiast!";
  String currentUserID = "testUserID123";
  bool _showDashboard = true;
  List<CompletedQuiz> userCompletedQuizzes = []; // Make this a state variable

  @override
  void initState() {
    super.initState();
    _fetchUserCompletedQuizzes(); // Fetch quizzes when the widget is first loaded
  }

  Future<void> _fetchUserCompletedQuizzes() async {
    List<CompletedQuiz> fetchedQuizzes = await fetchUserCompletedQuizzes();
    setState(() {
      userCompletedQuizzes = fetchedQuizzes;
    });
  }

  Future<List<CompletedQuiz>> fetchUserCompletedQuizzes() async {
    List<CompletedQuiz> completedQuizzes = [];

    // Assuming you have a variable called currentUserID for the logged-in user
    CollectionReference userScores = FirebaseFirestore.instance.collection('userScores');
    DocumentReference userDocRef = userScores.doc(currentUserID);

    QuerySnapshot quizResults = await userDocRef.collection('quizResults').get();

    for (var doc in quizResults.docs) {
      var data = doc.data() as Map<String, dynamic>;
      completedQuizzes.add(
        CompletedQuiz(
          quizName: "${data['mainSubject']} - ${data['subject']}",
          score: data['score'],
          totalQuestions: data['totalQuestions'], // Add this line
          timestamp: (data['dateTaken'] as Timestamp).toDate(),
        ),
    
      );
    }

    return completedQuizzes;
  }

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
