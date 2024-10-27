//底部提示栏
import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF755DC1), fontWeight: FontWeight.w500), // 设置文字颜色为红色
        ),
        backgroundColor: Colors.white, // 设置背景为黑色
        duration: const Duration(seconds: 2), // 持续时间
      ),
    );
  }
  static void showFailure(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color:Colors.red, fontWeight: FontWeight.w500), // 设置文字颜色为红色
        ),
        backgroundColor: Colors.white, // 设置背景为黑色
        duration: const Duration(seconds: 2), // 持续时间
      ),
    );
  }

}