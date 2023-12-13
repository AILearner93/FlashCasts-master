import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../landing_page/resources/resources.dart';

/////////////// Otp Signup
class EmailVerifiedPop extends StatefulWidget {
  @override
  _EmailVerifiedPopState createState() => _EmailVerifiedPopState();
}

class _EmailVerifiedPopState extends State<EmailVerifiedPop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Get.width * .9,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: Get.width * .03),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                              height: Get.height * .025,
                              child: Icon(
                                Icons.clear,
                                size: 60.h,
                              )),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Get.height * .02,
                  ),
                  SizedBox(
                      height: Get.height * .13,
                      child: Icon(
                        Icons.offline_share,
                        size: 60.h,
                      )),
                  SizedBox(
                    height: Get.height * .02,
                  ),
                  Text('Verification Link sent',
                      style: R.textStyles.poppins().copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: Get.height * .024)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
                    child: Text(
                      'Please check you email to verify your email address',
                      style: R.textStyles.poppins().copyWith(
                          color: Colors.black54, fontSize: Get.width * .04),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * .03,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Get.height * .005,
                        horizontal: Get.width * .1),
                    child: MaterialButton(
                      onPressed: () async {
                        Get.back();
                      },
                      elevation: 0,
                      color: R.colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.symmetric(
                        vertical: Get.height * .015,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Check Email',
                            style: R.textStyles.poppins().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: Get.height * .02,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Get.height * .03,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
