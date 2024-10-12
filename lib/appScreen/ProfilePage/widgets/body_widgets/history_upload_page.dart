// 历史上传数据
import 'package:flutter/material.dart';

class HistoryUploadPage extends StatelessWidget{

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
       leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('History Uploads', 
        style: TextStyle(
           color: Color(0xFF755DC1),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
      )
    );
  }
}