// 点击头像查看别人的个人主页
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/bar_widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/other_person_card.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/User/getuser_api.dart';
import 'package:gym_detector_ios/widgets/Leadline_bar.dart';
// ignore: must_be_immutable
class OthersProfilePage extends StatefulWidget {
  final bool isOneself = false;
  final String user_id; //被访问人的id
  OthersProfilePage({required this.user_id});
  _OthersProfilePageState createState() => _OthersProfilePageState();
}

class _OthersProfilePageState extends State<OthersProfilePage> {
  var selected = 0;
  final pageController = PageController();
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future:  GetuserApi.fetchUserData({
          'user_id': widget.user_id,
          'own_id': GlobalUser().user!.user_id,
        }),// 异步顺序加载数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading data: ${snapshot.error}')); // 错误处理
          } else if (snapshot.hasData && snapshot.data != null) {
            final person = snapshot.data!['person'];
            bool isFollowed=snapshot.data!['isFollowed'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 25,
                      right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            //返回之前页面
                            Navigator.pop(context);
                          },
                          child: LeadlineBar(
                              geticon: Icons.arrow_back,
                              getcolor: Color.fromARGB(255, 206, 163, 219))),
                      GestureDetector(
                          onTap: () async {
                            //弹窗确认关注与否
                            await GetuserApi.comfirmOperateFollow(context,  {
                                'user_id': GlobalUser().getUser()!.user_id, // 关注者id
                                'to_user_id': widget.user_id //被关注者id
                              }, isFollowed);
                            setState(() {
                              isFollowed
                                  ? person.followers_num++
                                  : person.followers_num--;
                              isFollowed=!isFollowed;
                            });
                          },
                          child: LeadlineBar(
                              geticon:
                                  isFollowed ? Icons.done : Icons.add,
                              getcolor: Color.fromARGB(255, 206, 163, 219))),
                    ],
                  ),
                ),
                OtherPersonCard(person1: person),
                BarList(
                  selected: selected,
                  callback: (int index) {
                    setState(() {
                      selected = index;
                    });
                  },
                  isOneself: false,
                ),
                Expanded(
                    child: IndexedStack(
                  index: selected,
                  children: [
                    // 显示第一个选项的内容
                    DynamiclistView(getperson: person, isOneself: false),
                  ],
                )),
              ],
            );
          } else {
            return const Center(
                child: Text('Failed to load data')); // 如果数据加载失败，显示错误提示
          }
        },
      ),
    );
  }
}
