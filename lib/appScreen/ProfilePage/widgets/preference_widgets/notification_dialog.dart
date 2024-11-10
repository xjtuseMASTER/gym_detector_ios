// 消息通知弹窗

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';

class NotificationDialog {
  static void show(BuildContext context) {
    UserPreferences userPreferences=GlobalUserPreferences().getUserPreferences()!;
    bool _inAppnotificationEnabled = userPreferences.isInApp_Reminder!; // 用于控制开关状态
    bool _outAppnotificationEnabled = userPreferences.outInApp_Reminder!; // 第二个开关的状态

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 圆角设计
              ),
              title: Text(
                'Notification Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF755DC1),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // 第一行：是否打开消息通知 1
                  SwitchListTile(
                    title: Text(
                      'In-app notification',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _inAppnotificationEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _inAppnotificationEnabled = value; // 切换开关状态
                      });
                    },
                  ),
                  // 第二行：是否打开消息通知 2
                  SwitchListTile(
                    title: Text(
                      'out-app notification',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _outAppnotificationEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _outAppnotificationEnabled = value; // 切换开关状态
                      });
                    },
                  ),
                ],
              ),
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
      },
    );
  }
}