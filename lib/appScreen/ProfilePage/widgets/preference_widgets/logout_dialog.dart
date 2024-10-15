import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/userScreen/main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDialog {
  static show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 圆角设计
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF755DC1),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Whether to log out the user?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // 使按钮居中
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async{
                //登出逻辑
                //清除数据
                await clearUserData();
                 // 关闭弹窗
                Navigator.of(context).pop();
                //导航至登陆页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>MainView())
                  );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Comfirm',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Cancle',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
  static Future<void> clearUserData () async{
    final pres=await SharedPreferences.getInstance();
    await pres.clear();
    GlobalUser().clearUser();
    GlobalUserPreferences().clearUserPreferences();
  }
}