import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz/landing_page/auth/singn_up.dart';

import 'package:responsive_builder/responsive_builder.dart';

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
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
          color: R.colors.background,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            R.images.mic,
                            height: isSmall ? 52.w : 33.w,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' QuizCards',
                                style: R.textStyles.poppins(
                                    fontSize: isSmall ? 32 : 42,
                                    color: R.colors.textColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    ' LISTEN',
                                    style: R.textStyles.poppins(
                                      fontSize: 17,
                                      color: R.colors.textColor,
                                      letterSpacing: 1.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Container(
                                    color: R.colors.textColor,
                                    width: 0.5.w,
                                    height: 15.h,
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(' SPEAK',
                                      style: R.textStyles.poppins(
                                        fontSize: 17,
                                        color: R.colors.textColor,
                                        letterSpacing: 1.sp,
                                      )),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Container(
                                    color: R.colors.textColor,
                                    width: 0.5.w,
                                    height: 15.h,
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(' LEARN',
                                      style: R.textStyles.poppins(
                                        fontSize: 17,
                                        color: R.colors.textColor,
                                        letterSpacing: 1.sp,
                                      )),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: isSmall ? 30.sp : 10.sp),
                        child: Text(
                          'The new voice \noperated quiz app',
                          maxLines: 3,
                          style: R.textStyles.poppins(
                            fontSize: isSmall ? 30 : 45,
                            color: R.colors.textColor,
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
                      heightBox(40),
                      Padding(
                        padding: EdgeInsets.only(
                          left: isSmall ? 130.w : 20.sp,
                        ),
                        child: SizedBox(
                          height: 40.h,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
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
                      ),
                    ],
                  )),
              isSmall
                  ? const SizedBox()
                  : Expanded(
                      flex: 1,
                      child: Image.asset(
                        R.images.music,
                      ),
                    ),
              // Expanded(flex: 1, child: Image.asset(R.images.music)),
            ],
          ),
        ),
      );
    });
  }
}
