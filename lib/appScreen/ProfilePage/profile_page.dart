import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/bodylist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/preferences_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/bar_widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/news_widgets/news_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_card.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/Leadline_bar.dart';
class ProfilePage extends StatefulWidget {
  var selected = 0;
  ProfilePage({
    required this.selected
  });
  

  @override
  State<ProfilePage> createState() => _ProflieState();
}
class _ProflieState extends State<ProfilePage>{

  
  final pageController = PageController();
  final person=GlobalUser().getUser();
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
                    Navigator.push(context, MaterialPageRoute(builder:(context)=>NewsPage()));
                  },
                  child: LeadlineBar(geticon: Icons.email,getcolor: Color.fromARGB(255, 206, 163, 219))
                ),
              ],
            ),
          ),
          PersonCard(person:person! ,isOneself: true),
           BarList(
            selected: widget.selected,
            callback: (int index) {
              setState(() {
                widget.selected = index;
              });
              pageController.jumpToPage(index);
            },
            isOneself: true,
          ),
          Expanded(
            child: IndexedStack(
              index: widget.selected,
              children: [
                // 显示第一个选项的内容
                BodylistView(getperson: person!),
                // 显示第二个选项的内容
                DynamiclistView(getperson: person!),
                // 显示第三个选项内容
                PreferencesView()
              ],
            ) 
          
          ),
        ],
      )
    );
  }
}