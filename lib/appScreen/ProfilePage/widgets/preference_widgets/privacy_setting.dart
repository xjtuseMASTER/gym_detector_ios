// 消息通知弹窗

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';

class PrivacySetting {
  static void show(BuildContext context) {
    UserPreferences userPreferences=GlobalUserPreferences().getUserPreferences()!;
    bool _notification1Enabled = userPreferences.isLikesVisible!; // 喜欢视频是否可见
    bool _notification2Enabled = userPreferences.isReleaseVisible!; // 发布视频是否可见
    bool _notification3Enabled = userPreferences.isCollectsVisible!; // 收藏视频是否可见

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 圆角设计
              ),
              title: const Text(
                'Privacy Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF755DC1),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // 喜欢视频是否可见
                  SwitchListTile(
                    title: const Text(
                      'Likes visible',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _notification1Enabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notification1Enabled = value; // 切换开关状态
                      });
                    },
                  ),
                  // 发布视频是否可见
                  SwitchListTile(
                    title: const Text(
                      'Release visible',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _notification2Enabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notification2Enabled = value; // 切换开关状态
                      });
                    },
                  ),
                   // 收藏视频是否可见
                  SwitchListTile(
                    title: const Text(
                      'Collects visible',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _notification3Enabled,
                    onChanged: (bool value) {
                      setState(() {
                         _notification3Enabled = value; // 切换开关状态
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