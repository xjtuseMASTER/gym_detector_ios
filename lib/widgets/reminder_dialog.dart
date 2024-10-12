// 提供语言更换窗口
import 'package:flutter/material.dart';

class ReminderDialog {
  final String information;//需要提示的信息
  final Function Oncomfirm;// 确认后要执行的方法
  ReminderDialog({required this.information,required this.Oncomfirm});
   void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 圆角设计
          ),
          title: Text('Reminder', style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF755DC1))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                information,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
          //确认按钮
           actionsAlignment: MainAxisAlignment.center, // 使取消按钮居中
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Oncomfirm();
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
                'Comfirm',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}