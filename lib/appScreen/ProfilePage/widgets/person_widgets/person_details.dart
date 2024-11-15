//点击信息卡片进入的详细个人信息页面

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_image.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_info.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/widgets/Leadline_bar.dart';
import 'package:netease_common_ui/utils/connectivity_checker.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/login/login_service.dart';
import 'package:netease_corekit_im/services/user_info/user_info_provider.dart';
import 'package:nim_core/nim_core.dart';
class PersonDetailsPage extends StatefulWidget {
  final Person person;
  const PersonDetailsPage({
    Key? key,
    required this.person,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PersonDetailsPageState();
}


class _PersonDetailsPageState extends State<PersonDetailsPage> {
  LoginService loginService = getIt<LoginService>();
  UserInfoProvider userInfoProvider = getIt<UserInfoProvider>();
  late NIMUser userInfo;
  
  _updateInfo() async {
    if (!await haveConnectivity()) {
      return;
    }
    userInfoProvider.updateUserInfo(userInfo).then((value) {
      if (value.isSuccess) {
        loginService.getUserInfo();
        // _backToPage();
      } else {
        // Fluttertoast.showToast(msg: S.of(context).requestFail);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    if (loginService.userInfo != null) {
      userInfo = NIMUser.fromMap(loginService.userInfo!.toMap());
    } else {
      userInfo = NIMUser();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用 Container 包裹整个背景
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 206, 163, 219), // 上半部分的紫色
              Colors.white, // 下半部分的白色
            ],
            stops: [0.3, 0.7], // 50% 紫色，50% 白色
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
             Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top, left: 25, right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context,GlobalUser().getUser());
                      },
                      child: LeadlineBar(geticon: Icons.arrow_back,getcolor:Colors.white)
                    )
                  ],
                ),
              ),
              PersonImage(person: person),
              PersonInfo(person: person),
            ],
          ),
        ),
      ),
    );
  }
}
}