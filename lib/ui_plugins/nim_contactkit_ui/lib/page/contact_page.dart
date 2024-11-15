// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_corekit_im/router/imkit_router_factory.dart';
import '../../../nim_conversationkit_ui/lib/page/add_friend_page.dart';
import '../../../nim_searchkit_ui/lib/page/search_kit_search_page.dart';
import '../contact_kit_client.dart';
import '../page/contact_kit_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../l10n/S.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key, this.config}) : super(key: key);

  final ContactUIConfig? config;

  @override
  State<StatefulWidget> createState() => _ContactState();
}

class _ContactState extends State<ContactPage> {
  ContactUIConfig get uiConfig =>
      widget.config ?? ContactKitClient.instance.contactUIConfig;

  ContactTitleBarConfig get _titleBarConfig => uiConfig.contactTitleBarConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _titleBarConfig.showTitleBar
          ? AppBar(
              title: Text(
                _titleBarConfig.title ?? S.of(context).contactTitle,
                style: TextStyle(
                    fontSize: 20,
                    color: _titleBarConfig.titleColor,
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: _titleBarConfig.centerTitle,
              actions: [
                if (_titleBarConfig.showTitleBarRight2Icon)
                  _titleBarConfig.titleBarRight2Icon ??
                      IconButton(
                        onPressed: () {
                          // goGlobalSearchPage(context);
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SearchKitGlobalSearchPage()));
                        },
                        icon: SvgPicture.asset(
                          'assets/ui_plugins_images/ic_search.svg',
                          width: 26,
                          height: 26,
                           
                        ),
                      ),
                if (_titleBarConfig.showTitleBarRightIcon)
                  _titleBarConfig.titleBarRightIcon ??
                      IconButton(
                          onPressed: () {
                            // goto add friend page
                            // goAddFriendPage(context);
                            Navigator.push(context,MaterialPageRoute(builder: (context) => const AddFriendPage()));
                          },
                          icon: SvgPicture.asset(
                            'assets/ui_plugins_images/ic_more.svg',
                            width: 26,
                            height: 26,
                             
                          )),
              ],
              elevation: 0,
            )
          : null,
      body: ContactKitContactPage(
        config: uiConfig,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
