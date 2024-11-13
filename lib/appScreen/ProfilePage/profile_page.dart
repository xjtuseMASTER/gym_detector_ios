import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/bodylist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/preferences_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/bar_widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_card.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
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
                SizedBox(height: 10,)
              ],
            ),
          ),
          PersonCard(person1:person! ,isOneself: true),
           BarList(
            selected: widget.selected,
            callback: (int index) {
              setState(() {
                widget.selected = index;
              });
            },
            isOneself: true,
          ),
          Expanded(
            child: IndexedStack(
              index: widget.selected,
              children: [
                // 显示第一个选项的内容
                BodylistView(),
                // 显示第二个选项的内容
                DynamiclistView(getperson: person!,isOneself: true),
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