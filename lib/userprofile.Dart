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
  final String username = "John Doe";
  final String userEmail = "johndoe@example.com";
  final String userBio = "Just another Flutter enthusiast!";
  final String currentUserID = "testUserID123";
  bool _showDashboard = false;

Stream<List<CompletedQuiz>> fetchUserCompletedQuizzesStream() {
  CollectionReference userScores = FirebaseFirestore.instance.collection('userScores');
  DocumentReference userDocRef = userScores.doc(currentUserID);

  return userDocRef.collection('quizResults').snapshots().map((snapshot) {
    // Printing all documents data
    for (var doc in snapshot.docs) {
      print(doc.data());
    }
    print("Total quizzes: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return CompletedQuiz(
        quizName: "${data['mainSubject']} - ${data['subject']}",
        score: data['score'],
        totalQuestions: data['totalQuestions'],
        timestamp: (data['dateTaken'] as Timestamp).toDate(),
      );
    }).toList();
  });
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
            Header(), // Ensure you have this widget defined or imported
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: MediaQuery.of(context).size.width * .025),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('/user_image.png'),
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
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                // Edit profile logic
              },
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDashboard = !_showDashboard;
                });
              },
              child: Text('See Scores (last 5 quizzes)'),
            ),
            if (_showDashboard) 
              StreamBuilder<List<CompletedQuiz>>(
                stream: fetchUserCompletedQuizzesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("An error occurred: ${snapshot.error}");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No quizzes completed yet.");
                  }
                  return QuizDashboard(completedQuizzes: snapshot.data!);
                },
              ),
          ],
        ),
      ),
    );
  }
}
