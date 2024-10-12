// 用户界面菜单栏
// 涉及 “动态”，“身体信息”，“偏好设置” 

import 'package:flutter/material.dart';

class BarList extends StatelessWidget{
  final int? selected;
  final Function? callback;
  final bool? isOneself;
  BarList({required this.selected,
          required this.callback,
          required this.isOneself});

  @override
  Widget build(BuildContext context) {
    final catagory = isOneself!?["Body Data","Dynamic","Preferences"]:["Dynamic"];
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => GestureDetector(
                onTap: () => callback!(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected == index ? Color.fromARGB(255, 195, 134, 220) : Colors.white,//自定义颜色
                  ),
                  child: Text(catagory[index],//类别
                      style: TextStyle(
                          color:
                          selected == index ? Colors.white : Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold)),
                ),
              ),
          separatorBuilder: (_, index) => const SizedBox(
                width: 20,
              ),
          itemCount: catagory.length),
    );
  }
}