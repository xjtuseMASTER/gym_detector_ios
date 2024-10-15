// 主题更换弹窗
// 提供语言更换窗口
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';

class ThemeDialog {
  
  // 显示语言选择弹窗
  static void show(BuildContext context) {
    UserPreferences userPreferences=GlobalUserPreferences().getUserPreferences()!;
    bool isLightTheme=userPreferences.isLightTheme!;
    String currentTheme=isLightTheme? 'Light Theme':'Dark Theme';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 圆角设计
          ),
          title: Text('Choose Theme', style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF755DC1))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.brightness_2_sharp, color: Colors.black),
                title: const Text(
                  'Dark Theme',
                   style: TextStyle(
                      fontWeight: FontWeight.w600, // 字体稍微粗一点
                    ),
                  ),
                  tileColor: currentTheme == 'Dark Theme' ? const Color.fromARGB(255, 232, 220, 250) : null, // 当前语言为英文时背景为灰色
                onTap: () {
                  // 切换到深色主题
                  currentTheme='Dark Theme';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_7_rounded, color: Colors.yellow),
                title: const Text(
                  'Light Theme',
                   style: TextStyle(
                      fontWeight: FontWeight.w600, // 字体稍微粗一点
                    ),
                  ),
                   tileColor: currentTheme == 'Light Theme' ?const Color.fromARGB(255, 232, 220, 250) : null, // 当前语言为英文时背景为灰色
                onTap: () {
                  // 切换到浅色主题
                  currentTheme='Light Theme';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
             // 取消按扭
           actionsAlignment: MainAxisAlignment.center, // 使取消按钮居中
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.grey, // 阴影颜色
                elevation: 5, // 阴影高度
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // 圆角
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}