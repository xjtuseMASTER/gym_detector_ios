// 自定义按钮类型
import 'package:flutter/material.dart';

class LeadlineBar extends StatelessWidget {
  final IconData geticon;
  final Color getcolor;
  // ignore: use_key_in_widget_constructors
  LeadlineBar({required this.geticon,required this.getcolor});
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: getcolor,
      ),
      child: Icon(geticon),
    );
  }
}

