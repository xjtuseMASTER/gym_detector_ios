import 'package:flutter/material.dart';

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
              width: 428,
              height: 457,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 27,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(//新密码输入
                  height: 56,
                  child: TextField(
                    controller: _newpasswordController,
                    obscureText: true, // 隐藏输入的内容
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'password',
                      labelStyle: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF9F7BFF),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 17,
                ),
               SizedBox(//确认新密码输入
                  height: 56,
                  child: TextField(
                    controller: _renewpasswordController,
                    textAlign: TextAlign.center,
                    obscureText: true, // 隐藏输入的内容
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'comfirm password',
                      labelStyle: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF9F7BFF),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                      ' Password must be at least 8 characters long',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF837E93),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                const SizedBox(
                  height: 18,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: 329,
                    height: 56,
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
                      child: const Text(
                        'Comfirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
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
    content: const Text(
      'Reset successfui,Return to Login!',
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 225, 174, 235), // 背景颜色
    duration: Duration(seconds: 2), // 显示2秒后自动消失
    behavior: SnackBarBehavior.floating, // 悬浮显示效果
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // 圆角
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 控制SnackBar位置
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
}
