import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: Image.asset(
              "assets/images/vector-1.png",
              width: 413,
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
                  'Log In',
                  style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 27,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF393939),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _passController,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  style: const TextStyle(
                    color: Color(0xFF393939),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Password',
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
                const SizedBox(
                  height: 25,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: 329,
                    height: 56,
                    child: ElevatedButton(
                                            onPressed: () async {
                        try {
                          await fetchUser();
                          Navigator.pushReplacementNamed(context, '/main'); // 导航到主页面
                        } catch (e) {
                          // 显示错误信息
                          print('Login failed: $e');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Login failed, please try again'),
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9F7BFF),
                      ),
                      child: const Text(
                        'Sign In',
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
                Row(
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: TextStyle(
                        color: Color(0xFF837E93),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 2.5,
                    ),
                    InkWell(  //可点击文本
                      onTap: () {
                        widget.controller.animateToPage(3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(  //可点击文本
                      onTap: () {
                        widget.controller.animateToPage(1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 13,
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
  await prefs.setString('user_id', person.ID);
  //保存登陆邮箱
  await prefs.setString('user_email', person.email);
  // 保存登录时间
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt('login_time', currentTime);
  }
 // 登录逻辑获取用户信息
Future<Person> fetchUserFromBackend(String user_email) async {
  final response = await http.get(
      Uri.parse('http://127.0.0.1:4523/m2/5245288-4913049-default/222467509'));

  if (response.statusCode == 200) {
    // 如果服务器返回200 OK，解析 JSON 数据
    final jsonResponse = json.decode(response.body);

    // 提取 data 部分
    final data = jsonResponse['data'];
    return Person.fromJson(data);
  } else {
    //处理错误
    // 如果请求失败，抛出异常
    throw Exception('Failed to load user data');
  }
}
//获取用户偏好设置
Future<UserPreferences> fetchUserPreferencesFromBackend(String user_email) async{
  final response= await http.get(Uri.parse('http://127.0.0.1:4523/m2/5245288-4913049-default/222919194?apifoxApiId=222919194'));
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

//获取用户存储用户信息
Future<void> fetchUser() async {
  try {
    Person user = await fetchUserFromBackend(_emailController.text);
    UserPreferences userPreferences= await fetchUserPreferencesFromBackend(_emailController.text);
    GlobalUser().setUser(user);
    GlobalUserPreferences().setUserPreferences(userPreferences);
    saveUserData(user);
  } catch (e) {
    // 错误处理
    print('Error fetching user: $e');
  }
}
}
