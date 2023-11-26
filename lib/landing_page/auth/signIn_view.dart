import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:responsive_builder/responsive_builder.dart';

import '../resources/resources.dart';
import '../utils/sized_box.dart';

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizes) {
      var isLarge = sizes.isLarge;
      var isMedium = sizes.isNormal;
      var isSmall = sizes.isMobile;
      var size = MediaQuery.sizeOf(context);
      return Scaffold(
        backgroundColor: R.colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              R.images.quizCards,
                              height: isSmall ? 52.w : 33.w,
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: isSmall ? 30.sp : 10.sp),
                              child: Text(
                                'The new voice \noperated quiz app',
                                maxLines: 3,
                                style: R.textStyles.poppins(
                                  fontSize: isSmall ? 30 : 45,
                                  color: R.colors.background,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            heightBox(40),
                            !isSmall
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(left: 155),
                                    child: Image.asset(
                                      R.images.music,
                                      height: 230.h,
                                    ),
                                  ),
                          ],
                        )),
                    widthBox(10),
                    isSmall
                        ? const SizedBox()
                        : Expanded(
                            flex: 1,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 12.w),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w) +
                                          EdgeInsets.only(top: 60.h),
                                  height: isSmall ? 400.h : 450.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: R.colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Sign In",
                                        style: R.textStyles.poppins(
                                            color: R.colors.signUpTextColor,
                                            fontSize: 25),
                                      ),
                                      TextFormField(
                                        decoration:
                                            R.decoration.fieldDecoration(
                                                hintStyle: R.textStyles.poppins(
                                                  color:
                                                      R.colors.signUpTextColor,
                                                  fontSize: 15,
                                                ),
                                                preIcon: Icon(
                                                  Icons.mail,
                                                  color: R.colors.iconColor,
                                                ),
                                                hintText: "Email address"),
                                      ),
                                      TextFormField(
                                        decoration:
                                            R.decoration.fieldDecoration(
                                                hintStyle: R.textStyles.poppins(
                                                  color:
                                                      R.colors.signUpTextColor,
                                                  fontSize: 15,
                                                ),
                                                preIcon: Icon(
                                                  Icons.lock,
                                                  color: R.colors.iconColor,
                                                ),
                                                hintText: "password"),
                                      ),
                                      SizedBox(
                                        width: size.width,
                                        height: 50.h,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(R
                                                        .colors
                                                        .singUpButtonColor)),
                                            onPressed: () {},
                                            child: Text(
                                              "Log In",
                                              style: R.textStyles.poppins(
                                                  color: R.colors.white,
                                                  fontSize: 5.sp),
                                            )),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 25.w),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Don't have an Account ?",
                                              style: R.textStyles.poppins(
                                                  color:
                                                      R.colors.signUpTextColor,
                                                  fontSize: 4.sp),
                                            ),
                                            widthBox(3),
                                            Text(
                                              "Sign Up",
                                              style: R.textStyles.poppins(
                                                  color: R
                                                      .colors.singUpButtonColor,
                                                  fontSize: 4.sp),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: CircularProfileAvatar("",
                                      radius: 10.w,
                                      child: Image.asset(R.images.profile)),
                                ),
                              ],
                            ))
                  ],
                ),
                heightBox(50.h),
                !isSmall
                    ? const SizedBox()
                    : Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 30.w),
                            padding: EdgeInsets.symmetric(horizontal: 10.w) +
                                EdgeInsets.only(top: 60.h),
                            height: 500.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: R.colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Sign Up",
                                  style: R.textStyles.poppins(
                                      color: R.colors.signUpTextColor,
                                      fontSize: 20),
                                ),
                                heightBox(10.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 150.w,
                                      child: TextFormField(
                                        decoration:
                                            R.decoration.fieldDecoration(
                                                hintStyle: R.textStyles.poppins(
                                                  color:
                                                      R.colors.signUpTextColor,
                                                  fontSize: 15,
                                                ),
                                                horizontalPadding: 0,
                                                preIcon: Icon(
                                                  Icons.account_circle_sharp,
                                                  color: R.colors.iconColor,
                                                ),
                                                hintText: "first Name"),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150.w,
                                      child: TextFormField(
                                        decoration:
                                            R.decoration.fieldDecoration(
                                                hintStyle: R.textStyles.poppins(
                                                  color:
                                                      R.colors.signUpTextColor,
                                                  fontSize: 15,
                                                ),
                                                preIcon: Icon(
                                                  Icons.account_circle_sharp,
                                                  color: R.colors.iconColor,
                                                ),
                                                hintText: "Last Name"),
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  decoration: R.decoration.fieldDecoration(
                                      hintStyle: R.textStyles.poppins(
                                        color: R.colors.signUpTextColor,
                                        fontSize: 15,
                                      ),
                                      preIcon: Icon(
                                        Icons.mail,
                                        color: R.colors.iconColor,
                                      ),
                                      hintText: "Email address"),
                                ),
                                TextFormField(
                                  decoration: R.decoration.fieldDecoration(
                                      hintStyle: R.textStyles.poppins(
                                        color: R.colors.signUpTextColor,
                                        fontSize: 15,
                                      ),
                                      preIcon: Icon(
                                        Icons.lock,
                                        color: R.colors.iconColor,
                                      ),
                                      hintText: "password"),
                                ),
                                SizedBox(
                                  width: size.width * 0.4,
                                  height: 45.h,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  R.colors.singUpButtonColor)),
                                      onPressed: () {},
                                      child: Text(
                                        "Sign Up",
                                        style: R.textStyles.poppins(
                                            color: R.colors.white,
                                            fontSize: 17),
                                      )),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 100.w),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Already Member?",
                                        style: R.textStyles.poppins(
                                            color: R.colors.signUpTextColor,
                                            fontSize: 15),
                                      ),
                                      widthBox(5.w),
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          "Sign In",
                                          style: R.textStyles.poppins(
                                              color: R.colors.singUpButtonColor,
                                              fontSize: 15),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          CircularProfileAvatar(
                            "",
                            radius: 30.w,
                            child: Image.asset(R.images.profile),
                          ),
                          // Container(
                          //   height: 120.h,
                          //   width: 100.w,
                          //   decoration: const BoxDecoration(
                          //       shape: BoxShape.circle, color: Colors.cyan),
                          // )
                        ],
                      )
              ],
            ),
          ),
        ),
      );
    });
  }
}
