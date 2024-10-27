import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final Size screenSize = MediaQuery.of(context).size;

    // 打印屏幕尺寸到控制台
    print('屏幕宽度: ${screenSize.width}');
    print('屏幕高度: ${screenSize.height}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                          await _fetchUserFromBackend(context, _emailController.text);
                          //多一道检查用户初始化数据的保险
                        if (GlobalUser().getUser() != null) {
                             Navigator.pushReplacementNamed(context, '/main'); // 导航到主页面
                        }
                          else{
                          CustomSnackBar.showFailure(context, 'Description User initialization failed! Try Again!');
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
    );
  }
  Future<void> saveUserData(Person person) async {
  final prefs = await SharedPreferences.getInstance();
  //保存登录者id
  await prefs.setString('user_id', person.user_id);
  //保存登陆邮箱
  await prefs.setString('user_email', person.email);
  // 保存登录时间
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt('login_time', currentTime);
  }
 // 登录逻辑获取用户信息
Future<void> _fetchUserFromBackend(BuildContext context,  String user_email) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Logining...');

    // 发送请求
    final response = await customHttpClient.get(
        Uri.parse('http://127.0.0.1:4523/m2/5245288-4913049-default/222467509').replace(
          queryParameters: {
            'user_emial': user_email, // 传入 user_id 参数
            'password':_passController.text //密码
          },
        ),
      );

    if (response.statusCode == 200) {
      // 请求成功
      //  提取 data 部分
      final jsonResponse=json.decode(response.body);
      final data = jsonResponse['data'];
      //保存登陆状态
      final person=Person(user_name: jsonResponse['data']['user_name'], selfInfo: jsonResponse['data']['selfInfo'], gender: jsonResponse['data']['gender'],
          avatar: jsonResponse['data']['avatar'], user_id:  jsonResponse['data']['user_id'], password:  jsonResponse['data']['password'], email:  jsonResponse['data']['email'], likes_num:  jsonResponse['data']['likes_num'], 
          birthday:  jsonResponse['data']['birthday'], collects_num:  jsonResponse['data']['collects_num'], followers_num:  jsonResponse['data']['followers_num']);
      saveUserData(person);
      //保存全局变量
      GlobalUser().setUser(person);
      //获取用户偏好设置信息
      UserPreferences userPreferences= await fetchUserPreferencesFromBackend(_emailController.text);
      GlobalUserPreferences().setUserPreferences(userPreferences);
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Login Successfully');
    } else {
      // 请求失败，根据状态码显示不同的错误提示
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
      // 隐藏加载对话框，显示错误提示框
      LoadingDialog.hide(context);
       CustomSnackBar.showFailure(context,errorMessage);
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    LoadingDialog.hide(context);
     CustomSnackBar.showFailure(context,'Network Error: Cannot fetch data');
  }
}

   
//获取用户偏好设置
Future<UserPreferences> fetchUserPreferencesFromBackend(String user_email) async{
  final response= await customHttpClient.get(Uri.parse('http://127.0.0.1:4523/m2/5245288-4913049-default/222919194?apifoxApiId=222919194').replace(
          queryParameters: {
            'user_emial': user_email, // 传入 user_id 参数
          },
        ),);
  if(response.statusCode==200){
    //解析jsonshuju
    final jsonResponse=json.decode(response.body);
    //提取data
    final data=jsonResponse['data'];
    
    return UserPreferences.fromJson(data);
  }
  else{
    throw Exception('Failed to load userpreferrences');
  }

}
}
