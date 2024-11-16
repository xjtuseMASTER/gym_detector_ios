// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common_ui/utils/connectivity_checker.dart';
import 'package:netease_corekit_im/router/imkit_router_factory.dart';
import 'package:netease_common_ui/widgets/search_page.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/login/login_service.dart';
import 'package:netease_corekit_im/services/user_info/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nim_core/nim_core.dart';

import '../conversation_kit_client.dart';
import '../../../../appScreen/HomePage/others_profile_page.dart';
import '../../../../appScreen/ProfilePage/profile_page.dart';
import '../l10n/S.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  Future<List<NIMUser>?> searchUserInfo(List<String> accountList) async {
    if (!await haveConnectivity()) {
      return null;
    }
    return getIt<UserInfoProvider>().fetchUserInfo(accountList);
  }

  @override
  Widget build(BuildContext context) {
    return SearchPage(
      title: S.of(context).addFriend,
      searchHint: S.of(context).addFriendSearchHint,
      buildOnComplete: true,
      builder: (context, keyword) {
        if (keyword.isEmpty)
          return Container();
        else {
          return FutureBuilder<List<NIMUser>?>(
              future: searchUserInfo([keyword]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 68,
                        ),
                        SvgPicture.asset(
                          'assets/ui_plugins_images/ic_search_empty.svg',
                           
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          S.of(context).addFriendSearchEmptyTips,
                          style:
                              TextStyle(color: Color(0xffb3b7bc), fontSize: 14),
                        )
                      ],
                    );
                  } else {
                    Future.delayed(Duration(milliseconds: 200), () {
                      if (getIt<LoginService>().userInfo?.userId ==
                          snapshot.data![0].userId) {
                        // gotoMineInfoPage(context);
                        Navigator.push(context,MaterialPageRoute(builder: (context) => ProfilePage(selected: 0)));
                      } else {
                        // goToContactDetail(context, snapshot.data![0].userId!);
                        Navigator.push(context,MaterialPageRoute(builder: (context) => OthersProfilePage(user_id: snapshot.data![0].userId!)));
                      }
                    });
                  }
                }
                return Container();
              });
        }
      },
    );
  }
}
