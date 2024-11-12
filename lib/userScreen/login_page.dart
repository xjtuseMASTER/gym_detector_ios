
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/Auth/login_api.dart';
import 'package:gym_detector_ios/services/utils/password_util.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final PageController controller;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // 获取屏幕的尺寸
    //final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
      child: 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.only(left: 15.w, top: 15.h),
            child: Image.asset(
              "assets/images/vector-1.png",
              width: 413.w,
              height: 457.h,
            ),
          ),
          SizedBox(
            height: 18.h,
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 50.h),
            child: Column(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'Log In',
                  style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 27.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                 SizedBox(
                  height: 50.h,
                ),
                TextField(
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
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide: BorderSide(
                        width: 1.w,
                        color: Color(0xFF837E93),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide: BorderSide(
                        width: 1.w,
                        color: Color(0xFF9F7BFF),
                      ),
                    ),
                  ),
                ),
                 SizedBox(
                  height: 30.h,
                ),
                TextField(
                  controller: _passController,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  style:  TextStyle(
                    color: Color(0xFF393939),
                    fontSize: 13.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration:  InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Color(0xFF755DC1),
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide: BorderSide(
                        width: 1.w,
                        color: Color(0xFF837E93),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide: BorderSide(
                        width: 1.w,
                        color: Color(0xFF9F7BFF),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  child: SizedBox(
                    width: 329.w,
                    height: 56.h,
                    child: ElevatedButton(
                                            onPressed: () async {
                        if(_emailController.text.isEmpty || _passController.text.isEmpty){
                           CustomSnackBar.showFailure(context, 'Please input correct Account and Password!');
                        }
                        else{
                        final queryParameters= {
                              'email': _emailController.text, // 传入 user_id 参数
                              'password': PasswordUtil.hashPassword(_passController.text)//密码
                            };
                        await LoginApi.fetchUserFromBackend(context,queryParameters);
                          //多一道检查用户初始化数据的保险
                        if (GlobalUser().user!= null) {
                             Navigator.of(context).pushNamedAndRemoveUntil(
                              '/main',
                              (Route<dynamic> route) => false, // 清空路由栈
                            );
                        }
                          else{
                          CustomSnackBar.showFailure(context, 'Description User initialization failed! Try Again!');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F7BFF),
                      ),
                      child:  Text(
                        'Sign In',
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
                  children: [
                     Text(
                      'Don’t have an account?',
                      style: TextStyle(
                        color: Color(0xFF837E93),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 2.5.w,
                    ),
                    InkWell(  //可点击文本
                      onTap: () {
                        widget.controller.animateToPage(3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child:  Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                InkWell(  //可点击文本
                      onTap: () {
                        widget.controller.animateToPage(1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}
