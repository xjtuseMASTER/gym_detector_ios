import 'package:flutter/material.dart';

class UploadPage extends StatelessWidget {
  final int index;

  UploadPage({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Page'),
      ),
      body: Center(
        child: Text(
          'Upload Page for Item $index',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}