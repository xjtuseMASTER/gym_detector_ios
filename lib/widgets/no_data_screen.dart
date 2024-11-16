import 'package:flutter/material.dart';

class NoDataScreen extends StatelessWidget {
  final String message;
  NoDataScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.weekend, // 沙发图标
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
