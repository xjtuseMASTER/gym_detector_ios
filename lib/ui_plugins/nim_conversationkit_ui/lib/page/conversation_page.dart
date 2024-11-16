// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common_ui/base/base_state.dart';
import '../conversation_kit_client.dart';
import '../widgets/conversation_list.dart';
import '../widgets/conversation_pop_menu_button.dart';
import 'package:netease_corekit_im/router/imkit_router_factory.dart';
import 'package:netease_common_ui/widgets/no_network_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../nim_searchkit_ui/lib/page/search_kit_search_page.dart';
import '../../../nim_contactkit_ui/lib/page/contact_page.dart';
import 'package:provider/provider.dart';

import '../l10n/S.dart';
import '../view_model/conversation_view_model.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({Key? key, this.config, this.onUnreadCountChanged})
      : super(key: key);

  final ValueChanged<int>? onUnreadCountChanged;
  final ConversationUIConfig? config;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends BaseState<ConversationPage> {
  late ConversationTitleBarConfig _titleBarConfig;

  ConversationUIConfig get uiConfig =>
      widget.config ?? ConversationKitClient.instance.conversationUIConfig;

  @override
  void initState() {
    super.initState();
    _titleBarConfig = uiConfig.titleBarConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _titleBarConfig.showTitleBar
          ? AppBar(
              centerTitle: _titleBarConfig.centerTitle,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_titleBarConfig.showTitleBarLeftIcon)
                    _titleBarConfig.titleBarLeftIcon ??
                        SvgPicture.asset(
                          'assets/ui_plugins_images/ic_yunxin.svg',
                          width: 32,
                          height: 32,
                        ),
                  if (_titleBarConfig.showTitleBarLeftIcon)
                    const SizedBox(
                      width: 12,
                    ),
                  Text(
                    _titleBarConfig.titleBarTitle ??
                        S.of(context).conversationTitle,
                    style: TextStyle(
                        fontSize: 20,
                        color: _titleBarConfig.titleBarTitleColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              elevation: 0.3,
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
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ContactPage()));
                  },
                  icon: SvgPicture.asset(
                    'assets/ui_plugins_images/icon_contact_unselected.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
                if (_titleBarConfig.showTitleBarRightIcon)
                  _titleBarConfig.titleBarRightIcon ??
                      ConversationPopMenuButton()
              ],
            )
          : null,
      body: ChangeNotifierProvider(
        create: (context) => ConversationViewModel(widget.onUnreadCountChanged,
            uiConfig.itemConfig.conversationComparator),
        builder: (context, child) {
          return Column(
            children: [
              if (!hasNetWork) NoNetWorkTip(),
              Expanded(
                child: ConversationList(
                  config: uiConfig.itemConfig,
                  onUnreadCountChanged: widget.onUnreadCountChanged,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
