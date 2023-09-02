import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz/landing.dart';
import 'package:quiz/quiz.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz/userprofile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a FirebaseOptions object.
  final firebaseOptions = FirebaseOptions(
      apiKey: "AIzaSyCeE0IEeWkxdqsmh8BlIjD2SyGzZegw8p0",
      authDomain: "quiz-60e0a.firebaseapp.com",
      databaseURL: "YOUR_DATABASE_URL",
      projectId: "quiz-60e0a",
      storageBucket: "quiz-60e0a.appspot.com",
      messagingSenderId: "568638882085",
      appId: "1:568638882085:web:0a92403719b705196edacc",
      measurementId: "G-XDFHTY18W2");

  // Initialize Firebase.
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(MaterialApp(
      title: 'Flashcast - Learn with us now!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        fontFamily: 'Eudoxus Sans',
        primaryColor: Color(0xFF4A7CFE),
      ),
      home: UserProfile()));
  //home: FirebaseAuth.instance.currentUser == null ? Landing() : Quiz()));
}
