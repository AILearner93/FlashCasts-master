import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/easy_dialog.dart';
import 'package:quiz/quiz.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'constant/user_data.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  TextEditingController forgotEmail = TextEditingController();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController registerEmail = TextEditingController();
  TextEditingController registerPassword = TextEditingController();
  TextEditingController registerFirstname = TextEditingController();
  TextEditingController registerLastname = TextEditingController();

  void login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (userCredential.user?.emailVerified == true) {
        Navigator.of(context)
            .pushReplacement(CupertinoPageRoute(builder: (context) => Quiz()));
      } else {
        EasyDialog().simpleDialog(
            context: context,
            title: 'Verification',
            description: 'Please check mail and verify account');
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'weak-password') {
        EasyDialog().simpleDialog(
            context: context,
            title: 'Error',
            description: 'The password provided is too weak');
      } else if (e.code == 'invalid-email') {
        EasyDialog().simpleDialog(
            context: context,
            title: 'Error',
            description: 'Incorrect email/password');
      } else if (e.code == 'wrong-password') {
        EasyDialog().simpleDialog(
            context: context,
            title: 'Error',
            description: 'Incorrect email/password');
      }
    } catch (e) {
      print(e);
    }
  }

  void register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: registerEmail.text.trim(),
        password: registerPassword.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user!.uid)
          .set({
        'firstname': registerFirstname.text.trim(),
        'lastname': registerLastname.text.trim(),
        'email': registerEmail.text.trim(),
      });

      userCredential.user?.sendEmailVerification();

      Navigator.of(context).pop();

      EasyDialog().simpleDialog(
          context: context,
          title: 'Verification',
          description: 'Please check mail and verify account');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        EasyDialog().simpleDialog(
            context: context,
            title: 'Error',
            description: 'The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        EasyDialog().simpleDialog(
            context: context,
            title: 'Error',
            description: 'The account already exists for that email');
      }
    } catch (e) {
      print(e);
    }
  }

  void forgotDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              padding: EdgeInsets.only(left: 32, right: 32),
              height: MediaQuery.of(context).size.height * .4,
              width: MediaQuery.of(context).size.width * .25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    'E-mail address',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: forgotEmail,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        )),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      if (forgotEmail.text.trim().isNotEmpty) {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: forgotEmail.text.trim());

                        Navigator.of(context).pop();

                        EasyDialog().simpleDialog(
                            context: context,
                            title: 'Reset Password',
                            description: 'Check your email!');
                      }
                    },
                    child: Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text('Reset',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          );
        });
  }

  void loginDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              padding: EdgeInsets.only(left: 32, right: 32),
              height: MediaQuery.of(context).size.height * .6,
              width: MediaQuery.of(context).size.width * .25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Need an account? ',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          registerDialog();
                        },
                        child: Text('Register'),
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Eudoxus Sans')),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    'E-mail address',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        )),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Password',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    controller: password,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        )),
                  ),
                  SizedBox(height: 32),
                  InkWell(
                    onTap: () {
                      if (email.text.trim().isEmpty ||
                          password.text.trim().isEmpty) {
                        EasyDialog().simpleDialog(
                            context: context,
                            title: 'Error',
                            description: 'Please enter your email/password');
                      } else {
                        login();
                      }
                    },
                    child: Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text('Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      forgotDialog();
                    },
                    child: Container(
                      height: 44,
                      width: double.infinity,
                      child: Center(
                        child: Text('Forgot Password?',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          );
        });
  }

  void registerDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              padding: EdgeInsets.only(left: 32, right: 32),
              height: MediaQuery.of(context).size.height * .5,
              width: MediaQuery.of(context).size.width * .25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          loginDialog();
                        },
                        child: Text('Login'),
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Eudoxus Sans')),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firstname',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: registerFirstname,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lastname',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: registerLastname,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'E-mail address',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: registerEmail,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              obscureText: true,
                              controller: registerPassword,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  InkWell(
                    onTap: () {
                      if (registerEmail.text.trim().isEmpty ||
                          registerPassword.text.trim().isEmpty ||
                          registerFirstname.text.trim().isEmpty ||
                          registerLastname.text.trim().isEmpty) {
                        EasyDialog().simpleDialog(
                            context: context,
                            title: 'Error',
                            description: 'Fields cannot be empty!');
                      } else {
                        register();
                      }
                    },
                    child: Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text('Register',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * .01,
            left: MediaQuery.of(context).size.width * .07,
            right: MediaQuery.of(context).size.width * .07),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 24),
                Text(
                  'Flashcast',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('About'),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Eudoxus Sans')),
                ),
                SizedBox(width: 24),
                TextButton(
                  onPressed: () {},
                  child: Text('Contact'),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Eudoxus Sans')),
                ),
                SizedBox(width: 32),
                InkWell(
                  onTap: () {
                    loginDialog();
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 24, right: 24, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                InkWell(
                  onTap: () {
                    registerDialog();
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .17),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME TO FLASHCAST',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Confused About Maths?\nLearn With Us Now!',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Learn with us all the courses and track your progress\nfast and efficently.',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    SizedBox(height: 32),
                    InkWell(
                      onTap: () {
                        loginDialog();
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 32, right: 32, top: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Spacer(),
                Image.asset(
                  'assets/login.png',
                  width: 500,
                  fit: BoxFit.contain,
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .1),
          ],
        ),
      ),
    );
  }
}
