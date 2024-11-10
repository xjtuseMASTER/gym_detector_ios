import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_temp_user.dart';
import 'package:gym_detector_ios/password_util.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import '../widgets/otp_form.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, required this.controller});
  final PageController controller;
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String? varifyCode;
  bool isOverTime = false;
  DateTime endTime = DateTime.now().add(const Duration(minutes: 1));

  Future<void> _submitEmail() async {
    try {
      final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/auth/email')
            .replace(
          queryParameters: {
            'email': GlobalTempUser().email,
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        GlobalTempUser().setAuthcode(data['auth_code']);
        print("11111");
        print(GlobalTempUser().authcode);
      } else {
        String errorMessage;
        if (response.statusCode == 404) {
          errorMessage = 'Resource not found';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server error';
        } else if (response.statusCode == 403) {
          errorMessage = 'Permission denied';
        } else {
          errorMessage = 'Unknown error';
        }
        LoadingDialog.hide(context);
        CustomSnackBar.showFailure(context, errorMessage);
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }
  //向后端发邮箱和密码
  Future<void> _submitRegister() async {
    try {
      final response = await customHttpClient.post(
        Uri.parse('${Http.httphead}/auth/register'),
        body: {
          "email": GlobalTempUser().email,
          "password": PasswordUtil.hashPassword(GlobalTempUser().password!)
        }
            
      );
      if (response.statusCode == 200) {
        //清除暂存信息
      GlobalTempUser().clearUser();
      CustomSnackBar.showSuccess(context, "SignUp Successfully! Please Login");


      } else {
        String errorMessage;
        if (response.statusCode == 404) {
          errorMessage = 'Resource not found';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server error';
        } else if (response.statusCode == 403) {
          errorMessage = 'Permission denied';
        } else {
          errorMessage = 'Unknown error';
        }
        LoadingDialog.hide(context);
        CustomSnackBar.showFailure(context, errorMessage);
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }

  void _resetCountdown() {
    setState(() {
      endTime = DateTime.now().add(const Duration(minutes: 1));
      isOverTime = false;
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(  // 新增 SingleChildScrollView
      child:
    Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.h, right: 15.w),
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
              padding: EdgeInsets.symmetric(horizontal: 50.w),
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
                      border: Border.all(width: 1.w, color: const Color(0xFF9F7BFF)),
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
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    child: SizedBox(
                      width: 329.w,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isOverTime) {
                            setState(() {
                              endTime = DateTime.now().add(const Duration(minutes: 1)); // 重置计时
                              isOverTime = false;
                            });
                            await _submitEmail();
                          } else {
                            if (GlobalTempUser().authcode == varifyCode!) {
                              LoadingDialog.show(context, 'Rigisting....');
                              await _submitRegister();
                              LoadingDialog.hide(context);
                              widget.controller.animateToPage(2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            } else {
                              CustomSnackBar.showFailure(context, "varifyCode Incorrect!");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9F7BFF),
                        ),
                        child: Text(
                          isOverTime ? 'Resend Code' : 'confirm',
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
                      //倒计时
                      Builder(
                      builder: (context) {
                        return TimerCountdown(
                          spacerWidth: 0,
                          enableDescriptions: false,
                          colonsTextStyle: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 13.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          timeTextStyle: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 13.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          format: CountDownTimerFormat.minutesSeconds,
                          endTime: endTime,
                          onEnd: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                isOverTime = true;
                              });
                            });
                          },
                        );
                      },
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
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'A 6-digit verification code has been sent to ${GlobalTempUser().email}',
                    style: TextStyle(
                      color: Color(0xFF837E93),
                      fontSize: 11.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 5.h,
          right: 15.w,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    ),
    )
  );
}
}