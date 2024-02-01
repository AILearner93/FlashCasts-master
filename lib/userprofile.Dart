import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/widget/quiz_dashboard.dart';
import 'package:quiz/models/completed_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz/quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constant/user_data.dart';
import 'landing_page/auth/onBoard.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 35,
          height: 35,
        ),
        SizedBox(width: 23),
        Text(
          'Flashcast',
          style: TextStyle(
              fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        InkWell(
          onTap: () async {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => Quiz()));
          },
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'Quiz',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        InkWell(
          onTap: () async {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => UserProfile()));
          },
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'User',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final String username = UserData.userM?.name ?? "";
  final String userEmail = UserData.userM?.email ?? "";
  final String userBio = "Just another Flutter enthusiast!";
  final String currentUserID = UserData.userM?.uid ?? "";
  bool _showDashboard = false;

  Stream<List<CompletedQuiz>> fetchUserCompletedQuizzesStream() {
    CollectionReference userScores =
        FirebaseFirestore.instance.collection('userScores');
    DocumentReference userDocRef = userScores.doc(currentUserID);

    return userDocRef.collection('quizResults').snapshots().map((snapshot) {
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
            Header(), // Adding the Header widget here
            SizedBox(height: 24),
            Center(
              child: UserData.userM?.imageUrl == null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage('assets/user_image.png'),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          NetworkImage(UserData.userM?.imageUrl ?? ""),
                    ),
            ),
            SizedBox(height: 20),
            Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
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
              child: Text('Toggle Scores View'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnBoardView()),
                );
              },
              child: Text('Logout'),
            ),
            if (_showDashboard)
              StreamBuilder<List<CompletedQuiz>>(
                stream: fetchUserCompletedQuizzesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("An error occurred: ${snapshot.error}");
                  }
                  bool dataIsEmpty =
                      snapshot.data == null || snapshot.data!.isEmpty;
                  if (dataIsEmpty) {
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
