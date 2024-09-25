import 'package:flutter/material.dart';
import 'package:gym_detector_ios/userScreen/login_page.dart';
import 'package:gym_detector_ios/userScreen/sign_up_page.dart';
import 'package:gym_detector_ios/userScreen/verify_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        controller: controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return LoginScreen(
              controller: controller,
            );
          } else if (index == 1) {
            return SingUpScreen(
              controller: controller,
            );
          } else {
            return VerifyScreen(
              controller: controller,
            );
          }
        },
      ),
    );
  }
}
