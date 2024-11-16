// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_common_ui/ui/dialog.dart';
import 'package:netease_common_ui/widgets/neListView/size_cache_widget.dart';
import 'package:netease_corekit_im/router/imkit_router.dart';
import 'package:netease_corekit_im/services/message/chat_message.dart';
import 'package:nim_chatkit/message/message_helper.dart';

import '../../l10n/S.dart';
import './pop_menu/chat_kit_pop_actions.dart';
import 'package:nim_core/nim_core.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../chat_kit_client.dart';
import '../../helper/chat_message_helper.dart';
import '../../view_model/chat_view_model.dart';
import 'item/chat_kit_message_item.dart';

class ChatKitMessageList extends StatefulWidget {
  final AutoScrollController scrollController;

  final ChatKitMessageBuilder? messageBuilder;

  final bool Function(ChatMessage message)? onMessageItemClick;

  final bool Function(ChatMessage message)? onMessageItemLongClick;

  final bool Function(String? userID, {bool isSelf})? onTapAvatar;

  final bool Function(String? userID, {bool isSelf})? onAvatarLongPress;

  final PopMenuAction? popMenuAction;

  final NIMTeam? teamInfo;

  final NIMMessage? anchor;

  final ChatUIConfig? chatUIConfig;

  ChatKitMessageList(
      {Key? key,
      required this.scrollController,
      this.anchor,
      this.messageBuilder,
      this.popMenuAction,
      this.onTapAvatar,
      this.teamInfo,
      this.chatUIConfig,
      this.onMessageItemClick,
      this.onAvatarLongPress,
      this.onMessageItemLongClick})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatKitMessageListState();
}

class ChatKitMessageListState extends State<ChatKitMessageList>
    with RouteAware {
  NIMMessage? findAnchor;

  //是否在当前页面
  bool isInCurrentPage = true;

  void _logI(String content) {
    Alog.i(tag: 'ChatKit', moduleName: 'message list', content: content);
  }

  bool _onMessageCopy(ChatMessage message) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessageCopy != null &&
        customActions!.onMessageCopy!(message)) {
      return true;
    }
    if (message.nimMessage.messageType == NIMMessageType.text &&
        message.nimMessage.content?.isNotEmpty == true) {
      Clipboard.setData(ClipboardData(text: message.nimMessage.content!));
      Fluttertoast.showToast(msg: S.of().chatMessageCopySuccess);
      return true;
    }
    var multiLineMap = MessageHelper.parseMultiLineMessage(message.nimMessage);
    if (multiLineMap != null) {
      var title = multiLineMap[ChatMessage.keyMultiLineTitle] as String;
      var content = multiLineMap[ChatMessage.keyMultiLineBody];
      Clipboard.setData(ClipboardData(text: content ?? title));
      Fluttertoast.showToast(msg: S.of().chatMessageCopySuccess);
      return true;
    }
    return false;
  }

  _scrollToMessageByUUID(String uuid) {
    var index = context
        .read<ChatViewModel>()
        .messageList
        .indexWhere((element) => element.nimMessage.uuid == uuid);
    if (index >= 0) {
      widget.scrollController.scrollToIndex(index);
    }
  }

  _scrollToAnchor(NIMMessage anchor) {
    var list = context.read<ChatViewModel>().messageList;
    if (list.isEmpty) {
      _logI('scrollToAnchor: messageList is empty');
      return;
    }
    final lastTimestamp = context
            .read<ChatViewModel>()
            .getAnchor(QueryDirection.QUERY_OLD)
            ?.timestamp ??
        DateTime.now().millisecondsSinceEpoch;
    if (anchor.timestamp >= lastTimestamp) {
      // in range
      findAnchor = null;
      int index = context
          .read<ChatViewModel>()
          .messageList
          .indexWhere((element) => element.nimMessage.uuid == anchor.uuid!);
      _logI(
          'scrollToAnchor: found time:${anchor.timestamp} >= $lastTimestamp, index found:$index');
      if (index >= 0) {
        widget.scrollController
            .scrollToIndex(index, duration: Duration(milliseconds: 500))
            .then((value) {
          widget.scrollController
              .scrollToIndex(index, preferPosition: AutoScrollPosition.middle);
        });
      }
    } else {
      _logI(
          'scrollToAnchor: not found in ${list.length} items, load more -->> ');
      widget.scrollController
          .scrollToIndex(list.length, duration: Duration(milliseconds: 1));
      _loadMore();
    }
  }

  bool _onMessageCollect(ChatMessage message) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessageCollect != null &&
        customActions!.onMessageCollect!(message)) {
      return true;
    }
    context.read<ChatViewModel>().collectMessage(message.nimMessage);
    Fluttertoast.showToast(msg: S.of().chatMessageCollectSuccess);
    return true;
  }

  bool _onMessageReply(ChatMessage message) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessageReply != null &&
        customActions!.onMessageReply!(message)) {
      return true;
    }
    context.read<ChatViewModel>().replyMessage = message;
    return true;
  }

  bool _onMessageForward(ChatMessage message) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessageForward != null &&
        customActions!.onMessageForward!(message)) {
      return true;
    }
    // 转发
    var sessionName = context.read<ChatViewModel>().chatTitle;
    var filterUser =
        context.read<ChatViewModel>().sessionType == NIMSessionType.p2p
            ? [context.read<ChatViewModel>().sessionId]
            : null;
    ChatMessageHelper.showForwardMessageDialog(context, (sessionId, sessionType,
        {String? postScript, bool? isLastUser}) {
      context.read<ChatViewModel>().forwardMessage(
          message.nimMessage, sessionId, sessionType,
          postScript: postScript);
    }, filterUser: filterUser, sessionName: sessionName);
    return true;
  }

  bool _onMessagePin(ChatMessage message, bool isCancel) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessagePin != null &&
        customActions!.onMessagePin!(message, isCancel)) {
      return true;
    }
    if (isCancel) {
      context.read<ChatViewModel>().removeMessagePin(message.nimMessage);
    } else {
      context.read<ChatViewModel>().addMessagePin(message.nimMessage);
    }
    return true;
  }

  bool _onMessageMultiSelect(ChatMessage message) {
    context.read<ChatViewModel>().isMultiSelected = true;
    context.read<ChatViewModel>().addSelectedMessage(message.nimMessage);
    hideKeyboard();
    return true;
  }

  bool _onMessageDelete(ChatMessage message) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessageDelete != null &&
        customActions!.onMessageDelete!(message)) {
      return true;
    }
    showCommonDialog(
            context: context,
            title: S.of().chatMessageActionDelete,
            content: S.of().chatMessageDeleteConfirm)
        .then((value) => {
              if (value ?? false)
                context.read<ChatViewModel>().deleteMessage(message)
            });
    return true;
  }

  void _resendMessage(ChatMessage message) {
    context.read<ChatViewModel>().sendMessage(message.nimMessage,
        replyMsg: message.replyMsg, resend: true);
  }

  bool _onMessageRevoke(ChatMessage message) {
    var customActions = widget.popMenuAction;
    if (customActions?.onMessageRevoke != null &&
        customActions!.onMessageRevoke!(message)) {
      return true;
    }
    showCommonDialog(
            context: context,
            title: S.of().chatMessageActionRevoke,
            content: S.of().chatMessageRevokeConfirm)
        .then((value) => {
              if (value ?? false)
                context
                    .read<ChatViewModel>()
                    .revokeMessage(message)
                    .then((value) {
                  if (!value.isSuccess) {
                    if (value.code == 508) {
                      Fluttertoast.showToast(
                          msg: S.of().chatMessageRevokeOverTime);
                    } else {
                      Fluttertoast.showToast(
                          msg: S.of().chatMessageRevokeFailed);
                    }
                  }
                })
            });
    return true;
  }

  _loadMore() async {
    // load old
    if (context.read<ChatViewModel>().messageList.isNotEmpty &&
        context.read<ChatViewModel>().hasMoreForwardMessages &&
        !context.read<ChatViewModel>().isLoading) {
      Alog.d(
          tag: 'ChatKit',
          moduleName: 'ChatKitMessageList',
          content: '_loadMore -->>');
      context.read<ChatViewModel>().fetchMoreMessage(QueryDirection.QUERY_OLD);
    }
  }

  PopMenuAction getDefaultPopMenuActions(PopMenuAction? customActions) {
    PopMenuAction actions = PopMenuAction();
    actions.onMessageCopy = _onMessageCopy;
    actions.onMessageReply = _onMessageReply;
    actions.onMessageCollect = _onMessageCollect;
    actions.onMessageForward = _onMessageForward;
    actions.onMessagePin = _onMessagePin;
    actions.onMessageMultiSelect = _onMessageMultiSelect;
    actions.onMessageDelete = _onMessageDelete;
    actions.onMessageRevoke = _onMessageRevoke;
    return actions;
  }

  @override
  void didPushNext() {
    isInCurrentPage = false;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    setState(() {
      isInCurrentPage = true;
    });
    super.didPopNext();
  }

  @override
  void initState() {
    super.initState();
    findAnchor = widget.anchor;
    Future.delayed(Duration.zero, () {
      IMKitRouter.instance.routeObserver
          .subscribe(this, ModalRoute.of(context)!);
    });
    _initScrollController();
  }

  //收到新消息后滑动到底部，对齐原生端交互
  _scrollToBottom() {
    _logI('_scrollToBottom');
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  _initScrollController() {
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        _logI('scrollController -->> load more');
        _loadMore();
      }
    });
    context.read<ChatViewModel>().scrollToEnd = _scrollToBottom;
  }

  @override
  void dispose() {
    IMKitRouter.instance.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (findAnchor != null) {
      _logI('build, try scroll to anchor:${findAnchor?.content}');
      _scrollToAnchor(findAnchor!);
    }

    return Consumer<ChatViewModel>(builder: (cnt, chatViewModel, child) {
      if (chatViewModel.sessionType == NIMSessionType.p2p &&
          chatViewModel.messageList.isNotEmpty) {
        NIMMessage? firstMessage = chatViewModel.messageList
            .firstWhereOrNull((element) =>
                element.nimMessage.messageDirection ==
                NIMMessageDirection.received)
            ?.nimMessage;
        if (firstMessage?.messageAck == true &&
            firstMessage?.hasSendAck == false &&
            isInCurrentPage) {
          chatViewModel.sendMessageP2PReceipt(firstMessage!);
        }
      }

      ///message list
      return Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizeCacheWidget(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  addAutomaticKeepAlives: false,
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: chatViewModel.messageList.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = chatViewModel.messageList[index];
                    ChatMessage? lastMessage =
                        index < chatViewModel.messageList.length - 1
                            ? chatViewModel.messageList[index + 1]
                            : null;
                    return AutoScrollTag(
                      controller: widget.scrollController,
                      index: index,
                      key: ValueKey(message.nimMessage.uuid),
                      highlightColor: Colors.black.withOpacity(0.1),
                      child: ChatKitMessageItem(
                        key: ValueKey(message.nimMessage.uuid),
                        chatMessage: message,
                        messageBuilder: widget.messageBuilder,
                        lastMessage: lastMessage,
                        popMenuAction:
                            getDefaultPopMenuActions(widget.popMenuAction),
                        scrollToIndex: _scrollToMessageByUUID,
                        onTapFailedMessage: _resendMessage,
                        onTapAvatar: widget.onTapAvatar,
                        onAvatarLongPress: widget.onAvatarLongPress,
                        chatUIConfig: widget.chatUIConfig,
                        teamInfo: widget.teamInfo,
                        onMessageItemClick: widget.onMessageItemClick,
                        onMessageItemLongClick: widget.onMessageItemLongClick,
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      );
    });
    // List messageList = widget.messageList;
  }
}
