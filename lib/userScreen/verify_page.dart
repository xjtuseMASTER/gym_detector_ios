import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/otp_form.dart';

class VerifyScreen extends StatefulWidget {
  final email;
  const VerifyScreen({super.key, required this.controller,required this.email});
  final PageController controller;
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String? varifyCode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Positioned(
            top: 5.h, // 按钮距离顶部的距离
            right: 15.w, // 按钮距离右侧的距离
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white), // 返回按钮图标
              onPressed: () {
                // 在这里添加返回操作
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 15.h, right: 15.w),
            child: Image.asset(
              "assets/images/vector-3.png",
              width: 428.w,
              height: 457.h,
            ),
          ),
          SizedBox(
            height: 18.h,
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 50.w),
            child: Column(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'Confirm the code\n',
                  style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 25.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Container(
                  width: 329.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    border:
                        Border.all(width: 1.w, color: const Color(0xFF9F7BFF)),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w),
                    child: OtpForm(
                      callBack: (code) {
                        varifyCode = code;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 32.h,
                ),
                ClipRRect(
                  borderRadius:  BorderRadius.all(Radius.circular(10.r)),
                  child: SizedBox(
                    width: 329.w,
                    height: 56.h,
                    child: ElevatedButton(
                      //实现验证码核对机制
                      onPressed: () {
                        widget.controller.animateToPage(2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F7BFF),
                      ),
                      child: Text(
                        'confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                 SizedBox(
                  height: 15.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Resend  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TimerCountdown(
                      spacerWidth: 0,
                      enableDescriptions: false,
                      colonsTextStyle: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      timeTextStyle:  TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      format: CountDownTimerFormat.minutesSeconds,
                      endTime: DateTime.now().add(
                        const Duration(
                          minutes: 2,
                          seconds: 0,
                        ),
                      ),
                      onEnd: () {},
                    ),
                  ],
                ),
                 SizedBox(
                  height: 15.h,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
              onTap: () {
                widget.controller.animateToPage(3,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
              child:  Text(
                        'Back',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      )
              ),
              SizedBox(height: 3.h),
               Text(
                'A 6-digit verification code has been sent to info@aidendesign.com',
                style: TextStyle(
                  color: Color(0xFF837E93),
                  fontSize: 11.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              )
              ],
            )
          ),
        ],
      ),
    );
  }
}
