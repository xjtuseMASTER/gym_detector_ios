import 'package:flutter/material.dart';
import 'package:gym_detector_ios/userScreen/findpassword_page.dart';
import 'package:gym_detector_ios/userScreen/login_page.dart';
import 'package:gym_detector_ios/userScreen/resetpassword_page.dart';
import 'package:gym_detector_ios/userScreen/sign_up_page.dart';
import 'package:gym_detector_ios/userScreen/verify_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key,this.initialPage=2});
   final int initialPage; // 定义初始页面参数


  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController controller = PageController(initialPage: 0);
  String user_email='';//用户邮箱
   @override
  void initState() {
    super.initState();
    // 使用传入的 initialPage 参数初始化 PageController
    controller = PageController(initialPage: widget.initialPage);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        controller: controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ResetpasswordPage(
              controller: controller, 
              user_email: user_email
              );
          } else if(index==1) {
              return FindpasswordPage(
              controller: controller, 
              onSubmitData: (data){
                setState(() {
                  user_email=data;
                });
            }
            );
          } else if (index==2){
            return LoginScreen(
              controller: controller,              
            );
          }
          else if (index==3){
            return SingUpScreen(
              controller: controller, 
             );
          }
          else if (index==4){
            return VerifyScreen(
              controller: controller, 
              );
          }
        },
      ),
    );
  }
}
