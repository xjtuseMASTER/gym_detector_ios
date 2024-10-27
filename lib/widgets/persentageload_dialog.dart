//带有进度条的加载框
import 'package:flutter/material.dart';

class PersentageloadDialog {

  static void showUploadDialog(BuildContext context, double progress) {
  showDialog(
    context: context,
    barrierDismissible: false, // 禁止点击背景关闭对话框
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 进度条
              LinearProgressIndicator(
                value: progress / 100, // 传入的上传百分比
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 20),
              // 显示上传百分比
              Text(
                '${progress.toStringAsFixed(2)}% uploaded',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  static void hide(BuildContext context) {
    Navigator.pop(context); // 关闭对话框
  }
}