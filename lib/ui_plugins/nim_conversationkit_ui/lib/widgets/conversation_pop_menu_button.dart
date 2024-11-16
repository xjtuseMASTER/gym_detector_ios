// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common_ui/extension.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:netease_corekit_im/router/imkit_router_constants.dart';
import 'package:netease_corekit_im/router/imkit_router_factory.dart';
import 'package:nim_core/nim_core.dart';
import '../page/add_friend_page.dart';
import 'package:netease_corekit_im/model/contact_info.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/message/message_provider.dart';
import 'package:netease_corekit_im/services/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import '../../../nim_chatkit_ui/lib/view/page/chat_page.dart';
import '../../../nim_contactkit_ui/lib/page/contact_kit_contact_selector_page.dart';
import '../l10n/S.dart';

class ConversationPopMenuButton extends StatelessWidget {
  const ConversationPopMenuButton({Key? key}) : super(key: key);

  _onMenuSelected(BuildContext context, String value) async {
    Alog.i(tag: 'ConversationKit', content: "onMenuSelected: $value");
    switch (value) {
      case "add_friend":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddFriendPage()));
        break;
      case "create_group_team":
      case "create_advanced_team":
        if (!(await Connectivity().checkNetwork(context))) {
          return;
        }
        // goToContactSelector(context, mostCount: 199, returnContact: true)
        Navigator.push(context,MaterialPageRoute(builder: (context) => ContactKitSelectorPage(mostSelectedCount: 199, returnContact: true)))
            .then((contacts) {
          if (contacts is List<ContactInfo> && contacts.isNotEmpty) {
            Alog.d(
                tag: 'ConversationKit',
                content: '$value, select:${contacts.length}');
            var selectName =
                contacts.map((e) => e.user.nick ?? e.user.userId!).toList();
            getIt<TeamProvider>()
                .createTeam(
              contacts.map((e) => e.user.userId!).toList(),
              selectNames: selectName,
              isGroup: value == 'create_group_team',
            )
                .then((teamResult) {
              if (teamResult != null && teamResult.team != null) {
                if (value == 'create_advanced_team') {
                  Map<String, String> map = Map();
                  map[RouterConstants.keyTeamCreatedTip] =
                      S.of(context).createAdvancedTeamSuccess;
                  getIt<MessageProvider>().sendTeamTipWithoutUnread(
                      teamResult.team!.id!, map,
                      time: teamResult.team!.createTime as int?);
                }
                Future.delayed(Duration(milliseconds: 200), () {
                  // goToTeamChat(context, teamResult.team!.id!);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => ChatPage(sessionId: teamResult.team!.id!, sessionType: NIMSessionType.team)));
                });
              }
            });
          }
        });
        break;
    }
  }

  List _conversationMenu(BuildContext context) {
    return [
      {
        'image': 'assets/ui_plugins_images/icon_add_friend.svg',
        'name': S.of(context).addFriend,
        'value': 'add_friend'
      },
      {
        'image': 'assets/ui_plugins_images/icon_create_group_team.svg',
        'name': S.of(context).createGroupTeam,
        'value': 'create_group_team'
      },
      {
        'image': 'assets/ui_plugins_images/icon_create_advanced_team.svg',
        'name': S.of(context).createAdvancedTeam,
        'value': 'create_advanced_team'
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) {
        return _conversationMenu(context)
            .map<PopupMenuItem<String>>(
              (item) => PopupMenuItem<String>(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      item['image'],
                       
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      item['name'],
                      style: const TextStyle(
                          fontSize: 14, color: CommonColors.color_333333),
                    ),
                  ],
                ),
                value: item['value'],
              ),
            )
            .toList();
      },
      icon: SvgPicture.asset(
        'assets/ui_plugins_images/ic_more.svg',
        width: 26,
        height: 26,
         
      ),
      offset: const Offset(0, 50),
      onSelected: (value) {
        _onMenuSelected(context, value);
      },
    );
  }
}
