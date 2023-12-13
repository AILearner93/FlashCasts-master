import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../landing_page/resources/resources.dart';

class CongratulationWidget extends StatefulWidget {
  final String description;
  CongratulationWidget({Key? key, required this.description}) : super(key: key);

  @override
  State<CongratulationWidget> createState() => _CongratulationWidgetState();
}

class _CongratulationWidgetState extends State<CongratulationWidget> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.back();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Center(
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: R.colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 2.h,
              ),
              Image.asset(
                R.images.checker,
                scale: 4,
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
                'Congratulations',
                textAlign: TextAlign.center,
                style: R.textStyles.poppins().copyWith(
                      fontSize: 18.sp,
                      color: R.colors.black,
                    ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: R.textStyles.poppins().copyWith(
                      fontSize: 16.sp,
                      color: R.colors.grey,
                    ),
              ),
              SizedBox(
                height: 3.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
