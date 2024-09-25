
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/userScreen/main_view.dart';
import 'appScreen/main_screen.dart'; // 替换为你的主页面文件路径


void main() {
  // 创建 PageController 实例
  final PageController _pageController = PageController();

  runApp(MyApp(controller: _pageController));
}

class MyApp extends StatelessWidget {
  // 接收 PageController 作为参数
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
      home: const MainView(),  // 将 PageController 传递给 LoginScreen
      routes: {
        '/main': (context) => MainScreen(),  // 登录成功后进入主页面
      },
    );
  }
}