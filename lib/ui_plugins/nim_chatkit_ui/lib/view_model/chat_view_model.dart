// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_common_ui/utils/connectivity_checker.dart';
import 'package:netease_corekit_im/im_kit_client.dart';
import 'package:netease_corekit_im/model/ait/ait_contacts_model.dart';
import 'package:netease_corekit_im/model/contact_info.dart';
import 'package:netease_corekit_im/repo/config_repo.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/contact/contact_provider.dart';
import 'package:netease_corekit_im/services/login/login_service.dart';
import 'package:netease_corekit_im/services/message/chat_message.dart';
import 'package:netease_corekit_im/services/message/nim_chat_cache.dart';
import 'package:nim_chatkit/chatkit_client_repo.dart';
import 'package:nim_chatkit/location.dart';
import 'package:nim_chatkit/message/message_reply_info.dart';
import 'package:nim_chatkit/message/message_revoke_info.dart';
import 'package:nim_chatkit/repo/chat_message_repo.dart';
import 'package:nim_chatkit/repo/chat_service_observer_repo.dart';
import '../helper/chat_message_helper.dart';
import '../helper/merge_message_helper.dart';
import 'package:nim_core/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../chat_kit_client.dart';
import '../l10n/S.dart';

class ChatViewModel extends ChangeNotifier {
  static const String logTag = 'ChatViewModel';

  static const String typeState = "typing";

  final String sessionId;

  final NIMSessionType sessionType;

  int _receiptTime = 0;

  int get receiptTime => _receiptTime;

  ///only for p2p
  bool isTyping = false;

  ///当消息列表中的数据少于这个值的时候自动拉取更多消息
  ///用于批量删除和删除回调
  final int _autoFetchMessageSize = 15;

  set receiptTime(int value) {
    _receiptTime = value;
    notifyListeners();
  }

  bool showReadAck;

  String chatTitle = '';
  ContactInfo? contactInfo;

  NIMTeam? teamInfo;

  //重新编辑的消息
  RevokedMessageInfo? _reeditMessage;

  RevokedMessageInfo? get reeditMessage => _reeditMessage;

  set reeditMessage(RevokedMessageInfo? value) {
    _reeditMessage = value;
    //如果被撤回的消息有被回复的消息，则重新编辑时需要显示被回复的消息
    if (value?.replyMsgId?.isNotEmpty == true) {
      NimCore.instance.messageService.queryMessageListByUuid(
          [value!.replyMsgId!], sessionId, sessionType).then((value) {
        if (value.data?.isNotEmpty == true) {
          replyMessage = ChatMessage(value.data!.first);
        }
      });
    }
    notifyListeners();
  }

  void resetTyping() {
    isTyping = false;
    notifyListeners();
  }

  ChatMessage? _replyMessage;

  ChatMessage? get replyMessage => _replyMessage;

  set replyMessage(ChatMessage? value) {
    _replyMessage = value;
    notifyListeners();
  }

  bool hasMoreForwardMessages = true;
  bool hasMoreNewerMessages = false;
  bool isLoading = false;

  bool initListener = false;
  static const int messageLimit = 100;

  //是否是多选状态
  bool _isMultiSelected = false;

  bool get isMultiSelected => _isMultiSelected;

  set isMultiSelected(bool value) {
    _isMultiSelected = value;
    if (!value) {
      _selectedMessages.clear();
    }
    notifyListeners();
  }

  //多选状态下选中的消息
  List<NIMMessage> _selectedMessages = [];

  List<NIMMessage> get selectedMessages => _selectedMessages.toList();

  ChatViewModel(this.sessionId, this.sessionType, {this.showReadAck = true}) {
    _setNIMMessageListener();
    if (sessionType == NIMSessionType.p2p) {
      getIt<ContactProvider>().getContact(sessionId).then((value) {
        contactInfo = value;
        chatTitle = value!.getName();
        notifyListeners();
      });
    } else if (sessionType == NIMSessionType.team) {
      ChatMessageRepo.queryTeam(sessionId).then((value) {
        if (value.isSuccess) {
          teamInfo = value.data;
          chatTitle = value.data!.name!;
          notifyListeners();
        }
      });
    }
    _initFetch(null);
  }

  List<ChatMessage> _messageList = [];

  List<ChatMessage> get messageList => _messageList.toList();

  //收到消息后滚动到最下边的回调
  void Function()? _scrollToEnd;

  set scrollToEnd(void Function() scrollToEnd) {
    _scrollToEnd = scrollToEnd;
  }

  NIMMessage? getAnchor(QueryDirection direction) {
    return direction == QueryDirection.QUERY_NEW
        ? _messageList.first.nimMessage
        : _messageList.last.nimMessage;
  }

  set messageList(List<ChatMessage> value) {
    _messageList = value;
    notifyListeners();
  }

  final subscriptions = <StreamSubscription>[];

  bool _isFilterMessage(NIMMessage message) {
    if (message.messageType == NIMMessageType.notification &&
        message.messageAttachment is NIMUpdateTeamAttachment) {
      var attachment = message.messageAttachment as NIMUpdateTeamAttachment;
      // 过滤被邀请人相关通知消息
      if (attachment.updatedFields.updatedBeInviteMode != null) {
        return true;
      }
      // 过滤群信息扩展参数变更通知消息
      if (attachment.updatedFields.updatedExtension != null) {
        return true;
      }
    }
    return false;
  }

  void _setNIMMessageListener() {
    if (initListener) return;
    initListener = true;
    _logI('message init listener');
    //new message
    subscriptions.add(
        ChatServiceObserverRepo.observeReceiveMessage().listen((event) async {
      _logI('receive msg -->> ${event.length}');
      if (event.length > 0) {
        _logI('onMessage 0:${event[0].toMap()}');
      }
      List<NIMMessage> list = event.where((element) {
        return element.sessionId == sessionId &&
            element.serverId! > 0 &&
            !_isFilterMessage(element);
      }).toList();
      if (list.isNotEmpty) {
        var res = await ChatMessageRepo.fillUserInfo(list);
        //用户数据填充完成后再更新过滤
        //解决非常罕见的在填充数据时，消息状态更新回调，导致消息多一条的问题
        _insertMessages(
            res
                .where((element) => !_updateNimMessage(element.nimMessage))
                .toList(),
            toEnd: false);
        _scrollToEnd?.call();
      }
    }));
    //message status change
    subscriptions
        .add(ChatServiceObserverRepo.observeMsgStatus().listen((event) {
      _logI(
          'onMessageStatus ${event.uuid} status change -->> ${event.status}, ${event.attachmentStatus}');
      if (_updateNimMessage(event) == false && event.sessionId == sessionId) {
        //如果更新失败则添加
        _insertMessages([ChatMessage(event)], toEnd: false);
      }
    }));

    subscriptions
        .add(ChatServiceObserverRepo.observeMessageDelete().listen((event) {
      if (event.isNotEmpty) {
        for (var msg in event) {
          if (msg.sessionId == sessionId && msg.sessionType == sessionType) {
            _messageList.remove(ChatMessage(msg));
            _selectedMessages.removeWhere((e) => e.uuid == msg.uuid);
          }
        }
        if (_messageList.length < _autoFetchMessageSize &&
            hasMoreForwardMessages) {
          fetchMoreMessage(QueryDirection.QUERY_OLD);
        }
        notifyListeners();
      }
    }));

    //昵称更新
    subscriptions.add(NIMChatCache.instance.contactInfoNotifier.listen((event) {
      if (event != null &&
          sessionType == NIMSessionType.p2p &&
          event.user.userId == sessionId) {
        contactInfo = event;
        chatTitle = event.getName();
      }
      notifyListeners();
    }));

    if (sessionType == NIMSessionType.team) {
      //team message receipt
      subscriptions.add(
          ChatServiceObserverRepo.observeTeamMessageReceipt().listen((event) {
        for (var element in event) {
          _updateTeamReceipt(element);
        }
      }));

      //群信息更新
      subscriptions.add(NIMChatCache.instance.teamInfoNotifier.listen((event) {
        if (event != null && event.id == sessionId) {
          teamInfo = event;
          chatTitle = event.name!;
          notifyListeners();
        }
      }));
    } else {
      //p2p message receipt
      subscriptions
          .add(ChatServiceObserverRepo.observeMessageReceipt().listen((event) {
        _updateP2PReceipt(event);
      }));

      subscriptions.add(ChatServiceObserverRepo.observeCustomNotification()
          .listen((notification) {
        if (notification.sessionId != sessionId ||
            notification.sessionType != NIMSessionType.p2p) {
          return;
        }
        var content = notification.content;
        if (content?.isNotEmpty == true) {
          Map<String, dynamic> options = jsonDecode(content!);
          if (options[typeState] == 1) {
            isTyping = true;
          } else {
            isTyping = false;
          }
          notifyListeners();
        }
      }));
    }

    subscriptions
        .add(ChatServiceObserverRepo.observeRevokeMessage().listen((event) {
      _logI('received revokeMessage notify and save a local message');
      if (event.message != null) {
        _onMessageRevoked(ChatMessage(event.message!));
      } else {
        _logI('received revokeMessage notify but message is null');
      }
    }));

    //监听Pin消息变化
    subscriptions
        .add(NIMChatCache.instance.pinnedMessagesNotifier.listen((event) {
      event = event as PinMessageEvent;
      if (event.type == PinEventType.remove && event.msgPin != null) {
        _updateMessagePin(event.msgPin!, delete: true);
      } else if (event.type == PinEventType.init) {
        for (var pin in event.pinMessages) {
          _updateMessagePin(pin);
        }
      } else if (event.msgPin != null) {
        _updateMessagePin(event.msgPin!);
      }
    }));
  }

  ///将消息插入列表，确保插入后的消息新消息在前，
  ///[toEnd] true:插入到最后，false:插入到最前
  void _insertMessages(List<ChatMessage> messages, {bool toEnd = true}) {
    if (messages.isEmpty) {
      return;
    }
    //如果第一条比最后一条旧，则反转,确保最新的消息在最前
    bool needReverse = messages.first.nimMessage.timestamp <
        messages.last.nimMessage.timestamp;
    if (needReverse) {
      messages = messages.reversed.toList();
    }
    if (_messageList.isEmpty) {
      _messageList.addAll(messages);
    } else {
      //获取第一条，结果为最新的消息
      var lastMsg = messages.first;
      var index = 0;
      if (toEnd) {
        //如果最新消息比消息列表中最后一条消息还要旧，则插入到最后
        if (lastMsg.nimMessage.timestamp <
            _messageList.last.nimMessage.timestamp) {
          index = _messageList.length;
        } else {
          //则从后遍历，插入到比自己新的消息之后的位置
          for (int i = _messageList.length - 1; i >= 0; i--) {
            //找到第一条比最新的消息更新的消息，插入到该消息后面
            if (lastMsg.nimMessage.timestamp <
                _messageList[i].nimMessage.timestamp) {
              index = i + 1;
              break;
            }
          }
        }
      } else if (lastMsg.nimMessage.timestamp <
          _messageList.first.nimMessage.timestamp) {
        //如果消息列表中的第一条消息比最新消息新，则从前遍历，插入到比自己旧的消息之前的位置
        for (int i = 0; i < _messageList.length; i++) {
          //找到第一条比最新的消息旧的消息，插入到该消息前面
          if (lastMsg.nimMessage.timestamp >
              _messageList[i].nimMessage.timestamp) {
            index = i;
            break;
          }
        }
      }

      _logD('insert message at $index to end:$toEnd');
      _messageList.insertAll(index, messages);
      _messageList
          .sort((a, b) => b.nimMessage.timestamp - a.nimMessage.timestamp);
    }
    notifyListeners();
  }

  void sendInputNotification(bool isTyping) {
    Map<String, dynamic> content = {typeState: isTyping ? 1 : 0};
    var json = jsonEncode(content);
    var notification = CustomNotification(
        sessionId: sessionId,
        sessionType: NIMSessionType.p2p,
        content: json,
        config: CustomNotificationConfig(
            enablePush: false, enableUnreadCount: false));
    ChatMessageRepo.sendCustomNotification(notification);
  }

  void _initFetch(NIMMessage? anchor) async {
    _logI('initFetch -->> anchor:${anchor?.content}');
    late NIMMessage message;
    hasMoreForwardMessages = true;
    if (anchor == null) {
      hasMoreNewerMessages = false;
      _fetchMoreMessageDynamic(
          anchor: null, direction: QueryDirection.QUERY_OLD, isInit: true);
    } else {
      hasMoreNewerMessages = true;
      message = anchor;
      _fetchMessageListBothDirect(message);
    }
  }

  _fetchMessageListBothDirect(NIMMessage anchor) {
    _logI('fetchMessageListBothDirect');
    _fetchMoreMessageDynamic(
        anchor: anchor, direction: QueryDirection.QUERY_OLD);
    _fetchMoreMessageDynamic(
        anchor: anchor, direction: QueryDirection.QUERY_NEW);
  }

  fetchMoreMessage(QueryDirection direction) {
    _fetchMoreMessageDynamic(
        anchor: getAnchor(direction), direction: direction);
  }

  _fetchMoreMessageDynamic(
      {NIMMessage? anchor,
      QueryDirection direction = QueryDirection.QUERY_OLD,
      bool isInit = false}) {
    _logI(
        '_fetchMoreMessageDynamic anchor ${anchor?.content}, time = ${anchor?.timestamp}, direction = $direction');

    isLoading = true;
    GetMessagesDynamicallyParam dynamicallyParam =
        GetMessagesDynamicallyParam(sessionId, sessionType);
    dynamicallyParam.limit = messageLimit;
    dynamicallyParam.direction = direction == QueryDirection.QUERY_OLD
        ? NIMGetMessageDirection.forward
        : NIMGetMessageDirection.backward;
    if (anchor != null) {
      dynamicallyParam.anchorClientId = anchor.uuid;
      dynamicallyParam.anchorServerId = anchor.serverId;
      if (direction == QueryDirection.QUERY_OLD) {
        dynamicallyParam.toTime = anchor.timestamp;
      } else {
        dynamicallyParam.fromTime = anchor.timestamp;
      }
    }
    //如果是Android端的初始化请求，则忽略更多信息的请求
    bool ignoreMoreInfo = Platform.isAndroid && isInit;
    ChatMessageRepo.getMessagesDynamically(dynamicallyParam,
            enablePin: IMKitClient.enablePin ? !ignoreMoreInfo : false,
            addUserInfo: !ignoreMoreInfo)
        .then((value) {
      if (value.isSuccess && value.data != null) {
        //如果是初始化，且是消息可信，则本地再获取历史消息，只针对Android
        if (ignoreMoreInfo && value.data!.isReliable == true) {
          _logD('getMessagesDynamically success, isInit and isReliable');
          MessageBuilder.createEmptyMessage(
                  sessionId: sessionId, sessionType: sessionType, timestamp: 0)
              .then((value) {
            if (value.isSuccess && value.data != null) {
              ChatMessageRepo.getHistoryMessage(
                      value.data!, direction, messageLimit,
                      enablePin: IMKitClient.enablePin)
                  .then((value) {
                if (value.isSuccess && value.data != null) {
                  _logI(
                      'getHistoryMessage success, length = ${value.data?.length}');
                  _onListFetchSuccess(value.data?.reversed.toList(), direction);
                } else {
                  _logI(
                      'getHistoryMessage failed, code = ${value.code}, error = ${value.errorDetails}');
                  _onListFetchFailed(value.code, value.errorDetails);
                }
              });
            } else {
              _logI(
                  'createEmptyMessage failed, code = ${value.code}, error = ${value.errorDetails}');
              _onListFetchFailed(value.code, value.errorDetails);
            }
          });
        } else {
          _logI(
              'getMessagesDynamically success, length = ${value.data?.messageList.length}');
          _onListFetchSuccess(value.data!.messageList, direction);
        }
      } else {
        _logI(
            'getMessagesDynamically failed, code = ${value.code}, error = ${value.errorDetails}');
        _onListFetchFailed(value.code, value.errorDetails);
      }
    });
  }

  _onListFetchSuccess(List<ChatMessage>? list, QueryDirection direction) {
    if (direction == QueryDirection.QUERY_OLD) {
      //先判断是否有更多，在过滤
      hasMoreForwardMessages = (list != null && list.isNotEmpty);
      _logD(
          'older forward has more:$hasMoreForwardMessages because list length =  ${list?.length}');
      list = _successMessageFilter(list);
      if (list != null) {
        _insertMessages(list, toEnd: true);
        if (list.isNotEmpty &&
            list[0].nimMessage.sessionType == NIMSessionType.p2p) {
          sendMessageP2PReceipt(list[list.length - 1].nimMessage);
        }
      }
    } else {
      hasMoreNewerMessages = list != null && list.isNotEmpty;
      list = _successMessageFilter(list);
      _logI('newer load has more:$hasMoreNewerMessages');
      if (list != null) {
        _insertMessages(list, toEnd: false);
        notifyListeners();
      }
    }
    isLoading = false;
  }

  //请求列表成功后过滤掉不需要添加的消息
  List<ChatMessage>? _successMessageFilter(List<ChatMessage>? list) {
    return list
        ?.where((element) =>
            !_isFilterMessage(element.nimMessage) &&
            !_updateNimMessage(element.nimMessage))
        .toList();
  }

  _onListFetchFailed(int code, String? errorMsg) {
    isLoading = false;
    _logI('onListFetchFailed code:$code, msg:$errorMsg');
  }

  void _updateTeamReceipt(NIMTeamMessageReceipt messageReceipt) {
    for (var message in _messageList) {
      if (message.nimMessage.uuid == messageReceipt.messageId) {
        message.unAckCount = messageReceipt.unAckCount!;
        message.ackCount = messageReceipt.ackCount!;
        _updateMessage(message);
      }
    }
  }

  void _updateP2PReceipt(List<NIMMessageReceipt> receipts) {
    for (var element in receipts) {
      if (receiptTime < element.time) {
        receiptTime = element.time;
      }
    }
  }

  void _updateMessage(ChatMessage message) {
    int pos = _messageList.indexOf(message);
    _logI('update message find $pos');
    if (pos >= 0) {
      _logI('update message at $pos');
      _messageList[pos] = message;
      notifyListeners();
    }
  }

  ///是否是被选中的消息
  bool isSelectedMessage(NIMMessage message) {
    return _selectedMessages
            .firstWhereOrNull((element) => element.uuid == message.uuid) !=
        null;
  }

  ///添加选中的消息
  void addSelectedMessage(NIMMessage message) {
    if (isSelectedMessage(message)) {
      return;
    }
    _selectedMessages.add(message);
    notifyListeners();
  }

  ///移除选中的消息
  void removeSelectedMessage(NIMMessage message) {
    _selectedMessages.removeWhere((element) => element.uuid == message.uuid);
    notifyListeners();
  }

  ///移除选中的消息
  void removeSelectedMessages(List<NIMMessage> messages) {
    for (var msg in messages) {
      _selectedMessages.removeWhere((element) => element.uuid == msg.uuid);
    }
    notifyListeners();
  }

  void _updateMessagePin(NIMMessagePin messagePin, {bool delete = false}) {
    for (int i = 0; i < _messageList.length; i++) {
      if (_isSameMessage(_messageList[i].nimMessage, messagePin)) {
        _messageList[i].pinOption = delete ? null : messagePin;
        notifyListeners();
        break;
      }
    }
  }

  void sendTextMessage(String text,
      {NIMMessage? replyMsg,
      List<String>? pushList,
      AitContactsModel? aitContactsModel,
      String? title}) async {
    var aitMap;

    if (aitContactsModel?.aitBlocks.isNotEmpty == true) {
      aitMap = aitContactsModel?.toMap();
    }

    var customData =
        ChatMessageHelper.getMultiLineMessageMap(title: title, content: text);

    var msgBuildResult = (title?.isNotEmpty == true)
        ? (await MessageBuilder.createCustomMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            attachment: NIMCustomMessageAttachment(data: customData)))
        : (await MessageBuilder.createTextMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            text: text,
          ));
    if (msgBuildResult.isSuccess && msgBuildResult.data != null) {
      if (sessionType == NIMSessionType.team &&
          pushList != null &&
          pushList.isNotEmpty) {
        msgBuildResult.data!.memberPushOption = NIMMemberPushOption(
            forcePushContent: title ?? text, forcePushList: pushList);
      }
      if (title?.isNotEmpty == true) {
        msgBuildResult.data!.pushContent = title;
      }
      if (aitMap != null) {
        msgBuildResult.data!.remoteExtension = {
          ChatMessage.keyAitMsg: aitMap,
        };
      }
      sendMessage(msgBuildResult.data!, replyMsg: replyMsg);
    }
  }

  void sendAudioMessage(String filePath, int fileSize, int duration,
      {NIMMessage? replyMsg}) {
    MessageBuilder.createAudioMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            filePath: filePath,
            fileSize: fileSize,
            duration: duration)
        .then((value) {
      if (value.isSuccess) {
        sendMessage(value.data!, replyMsg: replyMsg);
      }
    });
  }

  void sendImageMessage(String filePath, int fileSize,
      {NIMMessage? replyMsg, String? imageType}) {
    MessageBuilder.createImageMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            filePath: filePath,
            fileSize: fileSize)
        .then((value) {
      if (value.isSuccess) {
        if (imageType?.isNotEmpty == true) {
          if (value.data!.remoteExtension != null) {
            value.data!.remoteExtension![ChatMessage.keyImageType] = imageType;
          } else {
            value.data!.remoteExtension = {ChatMessage.keyImageType: imageType};
          }
        }
        sendMessage(value.data!, replyMsg: replyMsg);
      }
    });
  }

  //发送位置消息，不能用位置消息回复其他消息
  void sendLocationMessage(LocationInfo location) {
    MessageBuilder.createLocationMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.address ?? '')
        .then((ret) {
      if (ret.isSuccess && ret.data != null) {
        ret.data!.content = location.name;
        sendMessage(ret.data!);
      }
    });
  }

  void sendVideoMessage(
      String filePath, int duration, int width, int height, String displayName,
      {NIMMessage? replyMsg}) {
    MessageBuilder.createVideoMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            filePath: filePath,
            duration: duration,
            width: width,
            height: height,
            displayName: displayName)
        .then((value) {
      if (value.isSuccess) {
        sendMessage(value.data!, replyMsg: replyMsg);
      }
    });
  }

  void sendFileMessage(String filePath, String displayName,
      {NIMMessage? replyMsg}) {
    NimCore.instance.nosService
        .upload(
            filePath: filePath,
            mimeType: 'image/png',
            sceneKey: 'nim_default_profile_icon')
        .then((value) {
      print('GeorgeTest: upload file success, url = ${value.data}');
    });
    MessageBuilder.createFileMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            filePath: filePath,
            displayName: displayName)
        .then((value) => sendMessage(value.data!, replyMsg: replyMsg));
  }

  void sendMessage(NIMMessage message,
      {NIMMessage? replyMsg, bool resend = false}) async {
    message.messageAck = await ConfigRepo.getShowReadStatus();
    //回调
    if (ChatKitClient.instance.messageAction != null) {
      ChatKitClient.instance.messageAction!(message);
    }
    message.config = NIMCustomMessageConfig(enablePush: true);
    if (message.pushPayload == null &&
        ChatKitClient.instance.chatUIConfig.getPushPayload != null) {
      message.pushPayload =
          ChatKitClient.instance.chatUIConfig.getPushPayload!.call(message);
    }
    var chatMessage = ChatMessage(message, replyMsg: replyMsg);
    if (resend == false) {
      //发送消息插入到列表最前面
      _messageList.insert(0, chatMessage);
      notifyListeners();
    } else {
      _onMessageSending(chatMessage);
    }
    if (replyMsg != null) {
      var msgInfo = ReplyMessageInfo(
          idClient: replyMsg.uuid!,
          scene: replyMsg.sessionType?.name,
          to: replyMsg.sessionId,
          from: getIt<LoginService>().userInfo?.userId,
          idServer: replyMsg.serverId?.toString(),
          time: replyMsg.timestamp);
      if (message.remoteExtension != null) {
        message.remoteExtension![ChatMessage.keyReplyMsgKey] = msgInfo.toMap();
      } else {
        message.remoteExtension = {ChatMessage.keyReplyMsgKey: msgInfo.toMap()};
      }
    }
    ChatMessageRepo.sendMessage(message: message, resend: resend).then((value) {
      _onMessageSend(value, chatMessage);
    });
  }

  void _onMessageSending(ChatMessage message) {
    message.nimMessage.status = NIMMessageStatus.sending;
    _updateMessage(message);
  }

  void _onMessageSend(NIMResult<NIMMessage> value, ChatMessage message) {
    _logI('_onMessageSend ${message.nimMessage.toMap()}');
    //如果是被拉黑，则提示
    if (value.code == ChatMessageRepo.errorInBlackList) {
      _saveBlackListTips();
    }
    if (value.data != null) {
      message.nimMessage = value.data!;
    }
    _updateNimMessage(message.nimMessage, resort: value.isSuccess);
  }

  void _saveBlackListTips() {
    MessageBuilder.createTipMessage(
            sessionId: sessionId,
            sessionType: sessionType,
            content: S.of().chatMessageSendFailedByBlackList)
        .then((value) {
      if (value.isSuccess && value.data != null) {
        value.data!.config =
            NIMCustomMessageConfig(enablePush: false, enableUnreadCount: false);
        NimCore.instance.messageService.saveMessageToLocalEx(
            message: value.data!, time: value.data!.timestamp);
        _messageList.insert(0, ChatMessage(value.data!));
        notifyListeners();
      }
    });
  }

  bool _updateNimMessage(NIMMessage nimMessage, {bool resort = false}) {
    int pos = _messageList
        .indexWhere((element) => nimMessage.uuid == element.nimMessage.uuid);
    if (pos >= 0) {
      _logI('update nim message at $pos');
      //如果列表中的附件已经是完成状态，而更新的文件是传输状态，则不更新
      if (!(_messageList[pos].nimMessage.attachmentStatus ==
              NIMMessageAttachmentStatus.transferred &&
          nimMessage.attachmentStatus ==
              NIMMessageAttachmentStatus.transferring)) {
        _messageList[pos].nimMessage = nimMessage;
      }
      if (resort) {
        _messageList
            .sort((a, b) => b.nimMessage.timestamp - a.nimMessage.timestamp);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  ///合并转发
  ///[exitMultiMode] 是否退出多选模式
  ///[postScript] 转发后的附言
  ///[sessionId] 转发的目标会话id
  ///[sessionType] 转发的目标会话类型
  ///[errorToast] 转发失败的提示
  void mergedMessageForward(String sessionId, NIMSessionType sessionType,
      {String? postScript,
      String? errorToast,
      bool exitMultiMode = true}) async {
    if (await haveConnectivity()) {
      _selectedMessages.removeWhere((element) =>
          element.status == NIMMessageStatus.fail ||
          element.status == NIMMessageStatus.sending);
      _selectedMessages.sort((a, b) => a.timestamp - b.timestamp);
      MergeMessageHelper.createMergedMessage(
              selectedMessages, sessionId, sessionType)
          .then((value) async {
        if (value.isSuccess && value.data != null) {
          value.data!.messageAck = await ConfigRepo.getShowReadStatus();
          ChatMessageRepo.sendMessage(message: value.data!).then((value) {
            if (value.code == ChatMessageRepo.errorInBlackList) {
              ChatMessageRepo.saveTipsMessage(sessionId, sessionType,
                  S.of().chatMessageSendFailedByBlackList);
            }
            if (postScript?.isNotEmpty == true) {
              ChatMessageRepo.sendTextMessageWithMessageAck(
                  sessionId: sessionId,
                  sessionType: sessionType,
                  text: postScript!);
            }
          });
        } else {
          _logI(
              'createMergedMessage failed, code = ${value.code}, error = ${value.errorDetails}');
          if (errorToast?.isNotEmpty == true) {
            Fluttertoast.showToast(msg: errorToast!);
          }
        }
        if (exitMultiMode) {
          isMultiSelected = false;
        }
        notifyListeners();
      });
    }
  }

  bool filterForwardMessage(bool Function(NIMMessage) filter) {
    var oldLength = _selectedMessages.length;
    _selectedMessages.removeWhere((element) => filter(element));
    notifyListeners();
    return oldLength > _selectedMessages.length;
  }

  ///逐条转发
  ///[exitMultiMode] 是否退出多选模式
  ///[postScript] 转发后的附言
  ///[sessionId] 转发的目标会话id
  ///[sessionType] 转发的目标会话类型
  void forwardMessageOneByOne(String sessionId, NIMSessionType sessionType,
      {String? postScript, bool exitMultiMode = true}) async {
    if (!await haveConnectivity()) {
      return;
    }
    _selectedMessages.removeWhere((element) =>
        element.status == NIMMessageStatus.fail ||
        element.status == NIMMessageStatus.sending);
    for (var element in _selectedMessages) {
      forwardMessage(element, sessionId, sessionType);
    }
    if (postScript?.isNotEmpty == true) {
      ChatMessageRepo.sendTextMessageWithMessageAck(
              sessionId: sessionId, sessionType: sessionType, text: postScript!)
          .then((msgSend) {
        if (msgSend.code == ChatMessageRepo.errorInBlackList) {
          ChatMessageRepo.saveTipsMessage(
              sessionId, sessionType, S.of().chatMessageSendFailedByBlackList);
        }
      });
    }
    if (exitMultiMode) {
      isMultiSelected = false;
    }
    notifyListeners();
  }

  ///逐条删除
  void deleteMessageOneByOne() async {
    if (!await haveConnectivity()) {
      return;
    }

    if (_selectedMessages.length < 100) {
      _deleteMsgList(_selectedMessages);
    } else {
      //远端删除消息，每次最多删除99条
      int i = 0;
      int j = 99;
      final deleteMessage = List.of(_selectedMessages);
      while (i < deleteMessage.length && j <= deleteMessage.length) {
        //异步操作防止触发频控
        await _deleteMsgList(
            deleteMessage.sublist(i, min(j, deleteMessage.length)));
        i = j;
        j = min(j + 99, deleteMessage.length);
      }
    }
  }

  //批量删除消息
  //如果是本地消息，则直接删除本地消息
  //如果是远程消息，则删除远程消息
  Future<void> _deleteMsgList(List<NIMMessage> deleteMsgList) async {
    var localMessage = deleteMsgList
        .where((element) =>
            element.status == NIMMessageStatus.fail ||
            (element.serverId ?? 0) <= 0)
        .toList();
    if (localMessage.isNotEmpty) {
      await ChatMessageRepo.deleteLocalMessageList(localMessage);
      var uuidList = localMessage.map((e) => e.uuid).toList();
      _messageList.removeWhere((e) => uuidList.contains(e.nimMessage.uuid));
    }

    var remoteMessage = deleteMsgList
        .where((element) =>
            element.status == NIMMessageStatus.success ||
            (element.serverId ?? 0) > 0)
        .toList();
    if (remoteMessage.isNotEmpty) {
      var remoteResult = await ChatMessageRepo.deleteMessageList(remoteMessage);
      if (remoteResult.isSuccess) {
        var uuidList = remoteMessage.map((e) => e.uuid).toList();
        _messageList.removeWhere((e) => uuidList.contains(e.nimMessage.uuid));
      }
    }
    isMultiSelected = false;
    notifyListeners();
    if (_messageList.length < _autoFetchMessageSize && hasMoreForwardMessages) {
      fetchMoreMessage(QueryDirection.QUERY_OLD);
    }
  }

  void forwardMessage(
      NIMMessage message, String sessionId, NIMSessionType sessionType,
      {String? postScript}) async {
    if (await haveConnectivity()) {
      message.messageAck = await ConfigRepo.getShowReadStatus();
      ChatMessageRepo.forwardMessage(message, sessionId, sessionType)
          .then((value) {
        if (value.code == ChatMessageRepo.errorInBlackList) {
          ChatMessageRepo.saveTipsMessage(
              sessionId, sessionType, S.of().chatMessageSendFailedByBlackList);
        }
        if (postScript?.isNotEmpty == true) {
          ChatMessageRepo.sendTextMessageWithMessageAck(
                  sessionId: sessionId,
                  sessionType: sessionType,
                  text: postScript!)
              .then((msgSend) {
            if (msgSend.code == ChatMessageRepo.errorInBlackList) {
              ChatMessageRepo.saveTipsMessage(sessionId, sessionType,
                  S.of().chatMessageSendFailedByBlackList);
            }
          });
        }
        notifyListeners();
      });
    }
  }

  void addMessagePin(NIMMessage message, {String? ext}) async {
    if (!await haveConnectivity()) {
      return;
    }
    ChatMessageRepo.addMessagePin(message, ext: ext).then((value) {
      if (value.isSuccess) {
        _updateMessagePin(NIMMessagePin(
            sessionId: message.sessionId!,
            sessionType: message.sessionType!,
            messageId: message.messageId,
            messageUuid: message.uuid));
      }
    });
  }

  void removeMessagePin(NIMMessage message, {String? ext}) async {
    if (!await haveConnectivity()) {
      return;
    }
    ChatMessageRepo.removeMessagePin(message, ext: ext).then((value) {
      if (value.isSuccess) {
        _updateMessagePin(
            NIMMessagePin(
                sessionId: message.sessionId!,
                sessionType: message.sessionType!,
                messageId: message.messageId,
                messageUuid: message.uuid),
            delete: true);
      }
    });
  }

  void collectMessage(NIMMessage message) {
    ChatMessageRepo.collectMessage(message);
  }

  ///delete message
  void deleteMessage(ChatMessage message) async {
    if (!await haveConnectivity()) {
      return;
    }

    ///删除消息,如果失败则调用本地删除
    ChatMessageRepo.deleteMessage(message.nimMessage).then((value) {
      if (value.isSuccess) {
        _onMessageDeleted(message);
      } else {
        ChatMessageRepo.deleteLocalMessage(message.nimMessage).then((value) {
          _onMessageDeleted(message);
        });
      }
    });
  }

  void _onMessageDeleted(ChatMessage message) {
    _messageList.remove(message);
    notifyListeners();
  }

  ///撤回消息
  Future<NIMResult<void>> revokeMessage(ChatMessage message) {
    return ChatMessageRepo.revokeMessage(message.nimMessage).then((value) {
      if (value.isSuccess) {
        _logI('revokeMessage success and save a local message');
        _onMessageRevoked(message);
      }
      return value;
    });
  }

  void _onMessageRevoked(ChatMessage revokedMsg) async {
    final localMessage = await ChatKitClientRepo.instance
        .onMessageRevoked(revokedMsg, S.of().chatMessageHaveBeenRevoked);
    if (localMessage.isSuccess && localMessage.data != null) {
      int pos = _messageList.indexOf(revokedMsg);
      if (pos >= 0) {
        _messageList[pos] = ChatMessage(localMessage.data!);
        _selectedMessages.removeWhere(
            (element) => element.uuid == revokedMsg.nimMessage.uuid);
        notifyListeners();
      }
    }
  }

  void sendMessageP2PReceipt(NIMMessage message) {
    ChatMessageRepo.markP2PMessageRead(sessionId: sessionId, message: message);
  }

  void sendTeamMessageReceipt(ChatMessage message) {
    ChatMessageRepo.markTeamMessageRead(message.nimMessage);
  }

  void downloadAttachment(NIMMessage message, bool thumb) {
    _logI('downloadAttachment message:${message.uuid}, thumb:$thumb');
    ChatMessageRepo.downloadAttachment(message: message, thumb: thumb);
  }

  bool _isSameMessage(NIMMessage nimMessage, NIMMessagePin messagePin) {
    if (nimMessage.messageId != null &&
        nimMessage.messageId != '-1' &&
        messagePin.messageId != null &&
        messagePin.messageId != '-1') {
      return nimMessage.messageId == messagePin.messageId;
    } else {
      return nimMessage.uuid == messagePin.messageUuid;
    }
  }

  void _logI(String content) {
    Alog.i(tag: 'ChatKit', moduleName: '$logTag $sessionId', content: content);
  }

  void _logD(String content) {
    Alog.d(tag: 'ChatKit', moduleName: '$logTag $sessionId', content: content);
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
