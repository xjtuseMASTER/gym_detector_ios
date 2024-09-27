import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget{
  final Map<String, dynamic> post;
  DetailPage({required this.post});

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail page'),
      ),
      body: 
      Column(
        children: [
          const Padding(padding:EdgeInsets.zero,
        child: Text(
          'detail show',
          style: TextStyle(
            fontSize: 12
          ),
            ),
          ),
          Padding(padding: EdgeInsets.zero,
           child: Image.asset(
            post['image'],
            height: 200,
            width: 100,
           ),
          )
        ]
      ),
    );
  }
  
}