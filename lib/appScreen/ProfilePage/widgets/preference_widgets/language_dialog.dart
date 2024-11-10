// 提供语言更换窗口
//已经弃用
import 'package:flutter/material.dart';

class LanguageDialog {
  // 显示语言选择弹窗
  static String _currentLanguage = 'English'; // 默认语言为英文
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 圆角设计
          ),
          title: Text('Choose Language', style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF755DC1))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.language, color: Colors.blue),
                title: const Text(
                  'English',
                   style: TextStyle(
                      fontWeight: FontWeight.w600, // 字体稍微粗一点
                    ),
                  ),
                tileColor: _currentLanguage == 'English' ?const Color.fromARGB(255, 232, 220, 250) : null, // 当前语言为英文时背景为灰色
                onTap: () {
                  // 切换到英文逻辑
                  _currentLanguage='English';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.language, color: Colors.green),
                title: const Text(
                  '中文',
                   style: TextStyle(
                      fontWeight: FontWeight.w600, // 字体稍微粗一点
                    ),
                  ),
                tileColor: _currentLanguage == '中文' ?const Color.fromARGB(255, 232, 220, 250) : null, 
                onTap: () {
                  // 切换到中文逻辑
                  _currentLanguage='中文';
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