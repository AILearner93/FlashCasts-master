import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quiz/constant/fiirebase_collection.dart';
import 'package:quiz/constant/user_data.dart';
import 'package:quiz/landing_page/auth/models/user_model.dart';

import '../../../quiz.dart';
import '../../base_view/base_screen.dart';

class FbAuth extends ChangeNotifier {
  bool isLoading = false;
  late UserM userModel;
  //firebase instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
// firebase auth function
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      setLoader(true);
      print("Signing in: $email ==> $password");
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.push(
        Get.context!,
        MaterialPageRoute(builder: (context) => const Quiz()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setLoader(false);
    }
  }

  Future<bool> createUserWithEmailPassword(
      String email, String password) async {
    try {
      setLoader(true);
      print("Sign Up: $email ==> $password");
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    } finally {
      setLoader(false);
    }
  }

  forgotPassword(String email) async {
    try {
      setLoader(true);
      await _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
      Fluttertoast.showToast(msg: "Reset email sent, please check your inbox");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setLoader(false);
    }
  }

  setUserData(UserM userM) async {
    try {
      var currentUser = _firebaseAuth.currentUser?.uid;

      var userDoc =
          await FBCollections.users.doc(currentUser).set(userM.toJson());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {}
  }

  Future fetchUserData() async {
    try {
      var currentUser = _firebaseAuth.currentUser?.uid;
      var userDoc = await FBCollections.users.doc(currentUser).get();
      if (userDoc.exists) {
        final UserM model= UserM.fromJson(userDoc.data() as Map<String, dynamic>);
        model.uid=currentUser;
        userModel= model;
        notifyListeners();
      }else{
        print("User is Null");
        // userModel=null;
        notifyListeners();
        return ;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    } finally {}
  }

  setLoader(val) {
    isLoading = val;
    notifyListeners();
  }

  update() {
    notifyListeners();
  }
}
