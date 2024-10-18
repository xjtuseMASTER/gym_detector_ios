
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';
import 'package:gym_detector_ios/userScreen/main_view.dart';
import 'appScreen/main_screen.dart'; // 替换为你的主页面文件路径
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  final PageController _pageController = PageController();

  runApp(MyApp(controller: _pageController));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: checkLoginStatus(), // 检查登录状态
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 显示加载指示器
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 处理错误
            return MainView();
          } else {
            final bool isLoggedIn = snapshot.data as bool;
            if (isLoggedIn) {
              return MainScreen(); // 登录状态有效，导航到主页面
            } else {
              return MainView(); // 登录状态无效，导航到登录页面
            }
          }
        },
      ),
      routes: {
        '/main': (context) => MainScreen(),  // 登录成功后进入主页面
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final String? email = prefs.getString('email');
    final int? loginTime = prefs.getInt('login_time');

    if (userId != null && email != null && loginTime != null) {
      // 检查登录时间是否超过7天
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - loginTime <= 7 * 24 * 60 * 60 * 1000) {
        // 登录未过期，恢复用户数据到全局变量类
        Person user=await fetchUserFromBackend(email);

        UserPreferences userPreferences=await fetchUserPreferencesFromBackend(email);

        GlobalUser().setUser(user);
        GlobalUserPreferences().setUserPreferences(userPreferences);
        return true; // 用户已登录且未过期
      }
    }
    return false; // 用户未登录或已过期
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
}