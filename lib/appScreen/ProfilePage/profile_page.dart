import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_info.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/custom_app_bar.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProflieState();
}
class _ProflieState extends State<ProfilePage>{

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
          const CustomAppBar(
            leftIcon: Icons.center_focus_weak,
            rightIcon: Icons.email,
          ),
          PersonInfo(person: person),
           BarList(
            selected: selected,
            callback: (int index) {
              setState(() {
                selected = index;
              });
              pageController.jumpToPage(index);
            },
          ),
          Expanded(
            child: IndexedStack(
              index: selected,
              children: [
                // 显示第一个选项的内容
                Container(
                  child: Text('Content for Menu 1'),
                ),
                // 显示第二个选项的内容
                DynamiclistView(),
                // 你可以继续添加更多选项的内容
                Container(
                  child: Text('Content for Menu 3'),
                ),
              ],
            ) 
          
          )
        ],
      )
    );
  }
}