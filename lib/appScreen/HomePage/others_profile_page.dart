// 点击头像查看别人的个人主页
import 'dart:async';

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/bar_widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/other_person_card.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/User/getuser_api.dart';
import 'package:gym_detector_ios/widgets/Leadline_bar.dart';
import 'package:netease_common_ui/ui/dialog.dart';
import 'package:netease_common_ui/utils/connectivity_checker.dart';
import 'package:netease_corekit_im/model/contact_info.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/contact/contact_provider.dart';
import 'package:netease_corekit_im/services/login/login_service.dart';
import 'package:nim_contactkit/repo/contact_repo.dart';
import 'package:nim_core/nim_core.dart';

import '../../ui_plugins/nim_chatkit_ui/lib/view/page/chat_page.dart';
import '../../ui_plugins/nim_contactkit_ui/lib/l10n/S.dart';

import 'package:gym_detector_ios/widgets/networkerror_screen.dart';
// ignore: must_be_immutable
class OthersProfilePage extends StatefulWidget {
  final bool isOneself = false;
  final String user_id; //被访问人的id
  OthersProfilePage({required this.user_id});
  _OthersProfilePageState createState() => _OthersProfilePageState();
}

class _OthersProfilePageState extends State<OthersProfilePage> {
  var selected = 0;
  bool isFriend = false;
  final pageController = PageController();
  var subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    ContactRepo.isFriend(widget.user_id).then((value) {
      setState(() {
        isFriend = value;
      });
    });

    subs.add(ContactRepo.registerFriendObserver().listen((event) {
      for (var e in event) {
        if (e.userId == widget.user_id) {
          setState(() {
            isFriend = true;
          });
        }
      }
    }));

    subs.add(ContactRepo.registerFriendDeleteObserver().listen((event) {
      for (var userId in event) {
        if (userId == widget.user_id) {
          setState(() {
            isFriend = false;
          });
        }
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (var sub in subs) {
      sub.cancel();
    }
  }

  void _deleteFriendConfirm(ContactInfo contact) {
    showCommonDialog(
            context: context,
            content:
                S.of(context).contactDeleteSpecificFriend(contact.getName()),
            positiveContent: S.of(context).contactDelete)
        .then((value) async {
      if ((value ?? false) && await haveConnectivity()) {
        ContactRepo.deleteFriend(contact.user.userId!).then((value) {
          Navigator.pop(context);
          if (!value.isSuccess) {
            // Fluttertoast.showToast(msg: value.errorDetails ?? '');
          }
        });
      }
    });
  }

  void _addFriend(BuildContext context, String userId) async {
    if (!await haveConnectivity()) {
      return;
    }

    if (getIt<LoginService>().userInfo?.userId == userId) {}
    //先判断是否在黑名单,如果在黑名单则将其从黑名单移除
    var isInBlackList = (await ContactRepo.isBlackList(userId)).data;
    if (isInBlackList == true) {
      await ContactRepo.removeBlacklist(userId);
    }
    ContactRepo.addFriend(userId, NIMVerifyType.verifyRequest).then((value) {
      if (value.isSuccess) {
        Navigator.pop(context);
        // Fluttertoast.showToast(msg: S.of(context).contactHaveSendApply);
      } else {
        // Fluttertoast.showToast(msg: value.errorDetails ?? '');
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: GetuserApi.fetchUserData({
          'user_id': widget.user_id,
          'own_id': GlobalUser().user!.user_id,
        }), // 异步顺序加载数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading data: ${snapshot.error}')); // 错误处理
          } else if (snapshot.hasData && snapshot.data != null) {
            final person = snapshot.data!['person'];
            bool isFollowed = snapshot.data!['isFollowed'];
            final contact = snapshot.data!['contact'];

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
                            Navigator.pop(context);
                          },
                          child: LeadlineBar(
                              geticon: Icons.arrow_back,
                              getcolor: Color.fromARGB(255, 206, 163, 219))),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                 
                                },
                                child: LeadlineBar(
                                    geticon: Icons.person,
                                    getcolor:
                                        Color.fromARGB(255, 206, 163, 219))),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  //弹窗确认关注与否
                                  await GetuserApi.comfirmOperateFollow(
                                      context,
                                      {
                                        'user_id': GlobalUser()
                                            .getUser()!
                                            .user_id, // 关注者id
                                        'to_user_id': widget.user_id //被关注者id
                                      },
                                      isFollowed);
                                  setState(() {
                                    isFollowed
                                        ? person.followers_num++
                                        : person.followers_num--;
                                    isFollowed = !isFollowed;
                                  });
                                },
                                child: LeadlineBar(
                                    geticon:
                                        isFollowed ? Icons.done : Icons.add,
                                    getcolor:
                                        Color.fromARGB(255, 206, 163, 219))),
                          ]),
                    ],
                  ),
                ),
                OtherPersonCard(person1: person),
              SizedBox(height: 30.h),
              // 直接放置 IndexedStack，而不包裹在 Expanded 中
              Expanded(
                child: DynamiclistView(
                  getperson: person,
                  isOneself: false,
                ),
              ),
              // 在 DynamiclistView 下方添加新的内容
              Visibility(
                visible: isFriend,
                child: 
                Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 70.h),  // 设置底部距离
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    child: SizedBox(
                      width: 329.w,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () async {
                           Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              sessionId: contact.user.userId!,
                                              sessionType:
                                                  NIMSessionType.p2p)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 162, 139, 226),
                        ),
                        child: Text(
                          'Send Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
                )
            ],
          );
        } else {
          return NetworkErrorScreen();
        }
      },
    ),
  );
}

}
