import 'package:flutter/material.dart';

class ChatlistPage extends StatefulWidget{

  ChatlistPage({Key? key}) : super(key: key);

  @override
  State<ChatlistPage> createState() => _ChatlistPageState();

}
class _ChatlistPageState extends State<ChatlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("聊天列表"),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text("聊天${index}"),
            subtitle: Text("这是聊天${index}的内容"),
          );
        },
      ),
    );
  }
}