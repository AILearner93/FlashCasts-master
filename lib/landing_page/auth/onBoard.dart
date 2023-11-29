import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz/landing_page/auth/singn_up.dart';

import 'package:responsive_builder/responsive_builder.dart';

import '../resources/dummy.dart';
import '../resources/resources.dart';
import '../utils/sized_box.dart';

class OnBoardView extends StatefulWidget {
  const OnBoardView({Key? key}) : super(key: key);

  @override
  State<OnBoardView> createState() => _OnBoardViewState();
}

class _OnBoardViewState extends State<OnBoardView> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizes) {
      var isLarge = sizes.isLarge;
      var isMedium = sizes.isNormal;
      var isSmall = sizes.isMobile;
      final screenSize = MediaQuery.of(context).size;
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
            color: R.colors.white,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      height: 200.h,
                                    ),
                                  ),
                            heightBox(30),
                            SizedBox(
                              height: 40.h,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              R.colors.singUpFreeButtonColor)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignUp()),
                                    );
                                  },
                                  child: Text(
                                    "Sign Up for free",
                                    style: R.textStyles.poppins(
                                        color: R.colors.black,
                                        fontSize: isSmall ? 12 : 3.sp,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        )),
                    isSmall
                        ? const SizedBox()
                        : Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(top: 15.h),
                              child: Image.asset(
                                R.images.music,
                                height: 480.h,
                              ),
                            ),
                          ),
                    // Expanded(flex: 1, child: Image.asset(R.images.music)),
                  ],
                ),
                isSmall ? heightBox(40) : heightBox(5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: Image.asset(R.images.reader)),
                    widthBox(isSmall ? 25 : 20),
                    Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Our Mission",
                              style: R.textStyles.poppins(
                                  color: R.colors.background,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmall ? 15.sp : 9.sp),
                            ),
                            heightBox(15),
                            Text(
                              DummyData.mission,
                              style: R.textStyles.poppins(
                                  color: R.colors.black.withOpacity(.70),
                                  fontWeight: FontWeight.normal,
                                  fontSize: isSmall ? 10.sp : 6.sp),
                            ),
                            heightBox(15),
                            Text(
                              DummyData.signUp,
                              style: R.textStyles.poppins(
                                  color: R.colors.black.withOpacity(.70),
                                  fontWeight: FontWeight.normal,
                                  fontSize: isSmall ? 10.sp : 6.sp),
                            ),
                            heightBox(5),
                          ],
                        )),
                    // Expanded(flex: 1, child: Image.asset(R.images.music)),
                  ],
                ),
                heightBox(20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Image.asset(
                          R.images.checker,
                        )),
                    widthBox(isSmall ? 25 : 20),
                    Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expert Crafted\nQuestions",
                              style: R.textStyles.poppins(
                                  color: R.colors.background,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmall ? 15.sp : 9.sp),
                            ),
                            heightBox(15),
                            Text(
                              DummyData.craftedQuestions,
                              style: R.textStyles.poppins(
                                  color: R.colors.black.withOpacity(.70),
                                  fontWeight: FontWeight.normal,
                                  fontSize: isSmall ? 10.sp : 6.sp),
                            ),
                            heightBox(15),
                            // Text(
                            //   DummyData.signUp,
                            //   style: R.textStyles.poppins(
                            //       color: R.colors.black.withOpacity(.70),
                            //       fontWeight: FontWeight.normal,
                            //       fontSize: isSmall ? 10.sp : 6.sp),
                            // ),
                            heightBox(5),
                          ],
                        )),
                    // Expanded(flex: 1, child: Image.asset(R.images.music)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
