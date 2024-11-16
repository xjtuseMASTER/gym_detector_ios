// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netease_common_ui/base/base_state.dart';
import 'package:netease_common_ui/widgets/transparent_scaffold.dart';
import 'package:netease_corekit_im/router/imkit_router_constants.dart';
import '../../view/chat_kit_message_list/item/pinMessage/chat_kit_pin_message_item.dart';
import '../../view_model/chat_pin_view_model.dart';
import 'package:nim_core/nim_core.dart';
import 'package:provider/provider.dart';

import '../../chat_kit_client.dart';
import '../../l10n/S.dart';
import '../chat_kit_message_list/item/chat_kit_message_item.dart';

///消息标记列表页面
class ChatPinPage extends StatefulWidget {
  final String sessionId;

  final NIMSessionType sessionType;

  final String chatTitle;

  final ChatUIConfig? chatUIConfig;

  final ChatKitMessageBuilder? messageBuilder;

  ChatPinPage(
      {Key? key,
      required this.sessionId,
      required this.sessionType,
      required this.chatTitle,
      this.chatUIConfig,
      this.messageBuilder})
      : super(key: key);

  @override
  _ChatPinPageState createState() => _ChatPinPageState();
}

class _ChatPinPageState extends BaseState<ChatPinPage> {
  ChatUIConfig? chatUIConfig;

  ChatKitMessageBuilder? messageBuilder;

  @override
  void initState() {
    super.initState();
    messageBuilder = widget.messageBuilder ??
        ChatKitClient.instance.chatUIConfig.messageBuilder;

    chatUIConfig = widget.chatUIConfig ?? ChatKitClient.instance.chatUIConfig;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            ChatPinViewModel(widget.sessionId, widget.sessionType),
        builder: (context, child) {
          return TransparentScaffold(
            title: S.of(context).chatMessageSignal,
            body: Consumer<ChatPinViewModel>(
              builder: (context, model, child) {
                if (model.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 68,
                        ),
                        SvgPicture.asset(
                          'assets/ui_plugins_images/ic_list_empty.svg',
                           
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          S.of(context).chatHaveNoPinMessage,
                          style:
                              TextStyle(color: Color(0xffb3b7bc), fontSize: 14),
                        )
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: model.pinnedMessages.length,
                  itemBuilder: (context, index) {
                    var message = model.pinnedMessages[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            RouterConstants.PATH_CHAT_PAGE,
                            ModalRoute.withName('/'),
                            arguments: {
                              'sessionId': widget.sessionId,
                              'sessionType': widget.sessionType,
                              'anchor': message.nimMessage
                            });
                      },
                      child: ChatKitPinMessageItem(
                        chatMessage: message,
                        chatTitle: widget.chatTitle,
                        messageBuilder: messageBuilder,
                        chatUIConfig: chatUIConfig,
                      ),
                    );
                  },
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 10);
                  },
                );
              },
            ),
          );
        });
  }
}
