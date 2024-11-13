
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gym_detector_ios/module/global_module/global_temp_user.dart';
import 'package:gym_detector_ios/services/api/Auth/signup_api.dart';
import 'package:gym_detector_ios/services/utils/checkvalid_utils.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/services/utils/password_util.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/otp_form.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//找回密码邮箱验证页面
class FindpasswordPage extends StatefulWidget {
  const FindpasswordPage({super.key, required this.controller,required this.onSubmitData});
  final PageController controller;
  final Function(String) onSubmitData;
  @override
  State<FindpasswordPage> createState() => _FindpasswordPageState();
}

class _FindpasswordPageState extends State<FindpasswordPage> {
  final TextEditingController _emailController = TextEditingController();
   DateTime endTime = DateTime.now().add(const Duration(minutes: 1));
  bool isSendVerifyCode=false;//是否已经发送验证码
  String verify_code='';//验证码
  bool isOutoftime=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(  // 新增 SingleChildScrollView
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Image.asset(
              "assets/images/vector-4.png",
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
                  'Input Your E-mail',
                  style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 27.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                SizedBox(
                  height: 56.h,
                  child: TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 15.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1.w,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1.w,
                          color: Color(0xFF9F7BFF),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 17.h,
                ),
                Visibility(
                  visible: isSendVerifyCode,  //只有发送了验证码才会显示验证码输入框
                  child:  Container(
                  width: 329.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    border:
                        Border.all(width: 1.w, color: const Color(0xFF9F7BFF)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 60.w),
                    child: OtpForm(
                      callBack: (code) {
                        verify_code = code;
                      },
                    ),
                  ),
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                ClipRRect(
                  borderRadius:  BorderRadius.all(Radius.circular(10.r)),
                  child: SizedBox(
                    width: 329.w,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: ()async {
                        if(isSendVerifyCode){
                          //验证码没有过期进行验证
                         if(!isOutoftime){
                            //验证码验证机制
                            //验证完跳转至重置密码页面
                            if (GlobalTempUser().authcode == PasswordUtil.hashPassword(verify_code!)) {
                            widget.onSubmitData(_emailController.text);
                            widget.controller.animateToPage(0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease);
                            }
                            else{
                               CustomSnackBar.showFailure(context, "varifyCode Incorrect!");
                            }
                         }
                         else{
                          //验证码过期重新请求后端发送验证码
                          setState(() {
                          endTime = DateTime.now().add(const Duration(minutes: 1));  // 重置计时
                          isOutoftime=false;
                          });

                         }
                        }
                        else{
                        //先检查邮箱是否符合规范
                        if(CheckvalidUtils.isEmailValid(_emailController.text)){
                         //显示验证码框
                         setState(() {
                           isSendVerifyCode=true;
                         });
                         final handle=await SignupApi.submitEmail(context, {
                                'email':  _emailController.text
                              });
                              if(handle.isError){
                                HandleHttpError.handleErrorResponse(context, handle.code);
                              }else{
                            final data=handle.data;
                          //暂时存信
                            GlobalTempUser().clearUser();
                            GlobalTempUser().setEmail(_emailController.text);
                            GlobalTempUser().setAuthcode(data['auth_code']!);
                              }
                        }
                        else{
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please input valid E-mail')),
                            );
                        }
                      }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F7BFF),
                      ),
                      child: Text(
                        isSendVerifyCode?(isOutoftime?'Resend Code':'Comfirm'):'Send Code',
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
                    Visibility(
                    visible: isSendVerifyCode,
                    child: 
                    Text(
                      'Resend  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    )
                    ),
                    //验证码有效倒计时
                    Visibility(
                    visible: isSendVerifyCode,
                    child: 
                    TimerCountdown(
                      spacerWidth: 0,
                      enableDescriptions: false,
                      colonsTextStyle:  TextStyle(
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
                      endTime: DateTime.now().add(
                        const Duration(
                          minutes: 1,
                          seconds: 0,
                        ),
                      ),
                      onEnd: () {
                        setState(() {
                          isOutoftime=true;

                        });
                      },
                    )
                    )
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
                widget.controller.animateToPage(2,
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
              Visibility(
              visible: isSendVerifyCode,
              child: 
              isSendVerifyCode? Text(
                'A 6-digit verification code has been sent to info@aidendesign.com',
                style: TextStyle(
                  color: Color(0xFF837E93),
                  fontSize: 11.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ):Text("")
              )
              ],
            )
          ),
        ],
      ),
      )
    );
  }

}
