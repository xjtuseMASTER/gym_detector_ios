import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ResetpasswordPage extends StatefulWidget {
  const ResetpasswordPage({super.key, required this.controller,required this.user_email});
  final PageController controller;
  final user_email;
  @override
  State<ResetpasswordPage> createState() => _ResetpasswordPageState();
}

class _ResetpasswordPageState extends State<ResetpasswordPage> {
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _renewpasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Image.asset(
              "assets/images/vector-5.png",
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
                  'Reset Your Password',
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
                SizedBox(//新密码输入
                  height: 56.h,
                  child: TextField(
                    controller: _newpasswordController,
                    obscureText: true, // 隐藏输入的内容
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      labelText: 'password',
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
               SizedBox(//确认新密码输入
                  height: 56.h,
                  child: TextField(
                    controller: _renewpasswordController,
                    textAlign: TextAlign.center,
                    obscureText: true, // 隐藏输入的内容
                    style: TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration:  InputDecoration(
                      labelText: 'comfirm password',
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
                ),
                 SizedBox(height: 3.h),
                 Text(
                      ' Password must be at least 8 characters long',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF837E93),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                SizedBox(
                  height: 18.h,
                ),
                ClipRRect(
                  borderRadius:  BorderRadius.all(Radius.circular(10.r)),
                  child: SizedBox(
                    width: 329.w,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        //先检查两次密码相不相同
                        if(_newpasswordController.text==_renewpasswordController.text){
                            //再检查密码格式规不规范
                            if(isPasswordValid(_newpasswordController.text))
                            {
                              //向后端传参密码
                              //显示成功弹窗
                              showSuccessSnackBar(context);
                              //返回登录页面
                              widget.controller.animateToPage(2,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease);
                            }
                            else{
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please input valid password!')),
                            );
                            }
                         
                        }
                        else{
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comfirm Your Password!')),
                            );
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F7BFF),
                      ),
                      child:  Text(
                        'Comfirm',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
 bool isPasswordValid(String password) {
  // 检查密码是否包含空格，长度是否大于等于8
  if (password.contains(' ') || password.length < 8) {
    return false; // 格式不合理
  }
  return true; // 格式合理
  }
  void showSuccessSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content:  Text(
      'Reset successfui,Return to Login!',
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 225, 174, 235), // 背景颜色
    duration: Duration(seconds: 2), // 显示2秒后自动消失
    behavior: SnackBarBehavior.floating, // 悬浮显示效果
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r), // 圆角
    ),
    margin:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // 控制SnackBar位置
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
}
