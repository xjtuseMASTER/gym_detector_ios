// 消息通知弹窗

import 'package:flutter/material.dart';

class NotificationDialog {
  static void show(BuildContext context) {
    bool _notification1Enabled = false; // 用于控制开关状态
    bool _notification2Enabled = false; // 第二个开关的状态

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
                    value: _notification1Enabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notification1Enabled = value; // 切换开关状态
                      });
                    },
                  ),
                  // 第二行：是否打开消息通知 2
                  SwitchListTile(
                    title: Text(
                      'In-app notification',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _notification2Enabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notification2Enabled = value; // 切换开关状态
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