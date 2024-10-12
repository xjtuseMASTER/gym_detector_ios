// 点击头像查看别人的个人主页
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/bar_widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_card.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/Leadline_bar.dart';
import 'package:gym_detector_ios/widgets/reminder_dialog.dart';

// ignore: must_be_immutable
class OthersProfilePage  extends StatefulWidget{
  final bool isOneself=false;
  final Person person;
  bool isFollowed=false;//是否已经关注此人进入这个界面之后拿去数据
  OthersProfilePage({required this.person}); 
_OthersProfilePageState createState()=>_OthersProfilePageState();

}

class _OthersProfilePageState extends State<OthersProfilePage>{
  var selected = 0;
  final pageController = PageController();
  final person=Person.personGenerator();//当前模拟，以后由后端直接返回一个person对象
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: LeadlineBar(geticon: Icons.arrow_back,getcolor: Color.fromARGB(255, 206, 163, 219))
                ),
                GestureDetector(
                  onTap: (){
                    getFollow();
                  },
                  child: LeadlineBar(geticon: widget.isFollowed?Icons.done:Icons.add,getcolor: Color.fromARGB(255, 206, 163, 219))
                ),
              ],
            ),
          ),
          PersonCard(person: person,isOneself: false),
           BarList(
            selected: selected,
            callback: (int index) {
              setState(() {
                selected = index;
              });
              pageController.jumpToPage(index);
            },
            isOneself: false,
          ),
          Expanded(
            child: IndexedStack(
              index: selected,
              children: [
                // 显示第一个选项的内容
                DynamiclistView(getperson: person),
              ],
            ) 
          
          ),
        ],
      )
    );
  }
  void getFollow(){
    ReminderDialog(Oncomfirm:comfirmFollow,information:widget.isFollowed? 'Do you want you unfollow him?':'Do you want you follow him?').show(context);//显示弹窗

  }
  void comfirmFollow(){
     // 这里的Oncomfirm为代传入的向后端更新数据的接口
     setState(() {
      widget.isFollowed=!widget.isFollowed;//改为关注状态并进行状态更新
    });
  }

  }