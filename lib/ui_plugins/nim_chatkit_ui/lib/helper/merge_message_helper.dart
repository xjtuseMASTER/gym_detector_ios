// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_corekit_im/model/custom_type_constant.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/contact/contact_provider.dart';
import 'package:netease_corekit_im/services/message/nim_chat_cache.dart';
import 'package:nim_chatkit/message/merge_message.dart';
import 'package:nim_chatkit/repo/chat_message_repo.dart';
import './chat_message_user_helper.dart';
import 'package:nim_core/nim_core.dart';

import 'chat_message_helper.dart';

class MergeMessageHelper {
  ///解析合并消息
  static MergedMessage? parseMergeMessage(NIMMessage message) {
    if (message.messageType == NIMMessageType.custom &&
        message.messageAttachment is NIMCustomMessageAttachment) {
      var data = (message.messageAttachment as NIMCustomMessageAttachment).data;
      if (data?[CustomMessageKey.type] ==
              CustomMessageType.customMergeMessageType &&
          data?[CustomMessageKey.data] is Map) {
        return MergedMessage.fromMap(
            (data![CustomMessageKey.data] as Map).cast<String, dynamic>());
      }
    }
    return null;
  }

  ///创建合并消息
  static Future<NIMResult<NIMMessage>> createMergedMessage(
      List<NIMMessage> messages,
      String sessionId,
      NIMSessionType sessionType) async {
    if (messages.isEmpty) {
      return NIMResult.failure(message: 'message list is empty');
    }
    final mergedMessage = await mergeMessage(messages);
    if (mergedMessage.isSuccess && mergedMessage.data != null) {
      final customMsgBuilder = await MessageBuilder.createCustomMessage(
          sessionId: sessionId,
          sessionType: sessionType,
          attachment: NIMCustomMessageAttachment(data: mergedMessage.data!));
      if (customMsgBuilder.isSuccess && customMsgBuilder.data != null) {
        customMsgBuilder.data!.pushContent =
            ChatMessageHelper.getMessageBrief(customMsgBuilder.data!);
        return NIMResult.success(data: customMsgBuilder.data!);
      } else {
        return NIMResult.failure(message: customMsgBuilder.errorDetails);
      }
    } else {
      return NIMResult.failure(message: mergedMessage.errorDetails);
    }
  }

  static int getMergedMessageDepth(NIMMessage message) {
    var mergeMsg = parseMergeMessage(message);
    if (mergeMsg != null) {
      return mergeMsg.depth ?? 0;
    }
    return 0;
  }

  ///合并消息，返回Map
  static Future<NIMResult<Map<String, dynamic>>> mergeMessage(
      List<NIMMessage> messageList) async {
    if (messageList.isEmpty) {
      return NIMResult.failure(message: 'merge message list is empty');
    }
    final messages = messageList;

    if (messages.isEmpty) {
      return NIMResult.failure(message: 'filtrated messages is empty');
    }
    final messageUpload =
        await ChatMessageRepo.uploadMergedMessageFile(messages);
    if (messageUpload.isSuccess && messageUpload.data != null) {
      final Map<String, dynamic> result = {};
      result[CustomMessageKey.type] = CustomMessageType.customMergeMessageType;
      String url = messageUpload.data!.url;
      String md5 = messageUpload.data!.md5;
      var depth = 0;
      String sessionId;
      String sessionName;
      sessionId = messages.first.sessionId!;
      if (messages.first.sessionType == NIMSessionType.p2p) {
        sessionName = await sessionId.getUserName(needAlias: false);
      } else if (messages.first.sessionType == NIMSessionType.team) {
        sessionName = NIMChatCache.instance.teamInfo?.name ?? sessionId;
      } else {
        sessionName = sessionId;
      }
      final List<MergeMessageAbstract> abstracts = List.empty(growable: true);
      for (int i = 0; i < messages.length; i++) {
        var message = messages[i];
        if (i < 3) {
          String userAccId = message.fromAccount!;
          String senderNick = (await getIt<ContactProvider>()
                      .getContact(userAccId, needFriend: false))
                  ?.getName(needAlias: false) ??
              userAccId;
          String content = ChatMessageHelper.getMessageBrief(message);
          abstracts.add(MergeMessageAbstract(
              senderNick: senderNick, content: content, userAccId: userAccId));
        }
        var mergeMsg = parseMergeMessage(message);
        if (mergeMsg != null &&
            mergeMsg.depth != null &&
            mergeMsg.depth! > depth) {
          depth = mergeMsg.depth!;
        }
      }
      depth++;
      result[CustomMessageKey.data] = MergedMessage(
              sessionId: sessionId,
              sessionName: sessionName,
              url: url,
              md5: md5,
              depth: depth,
              abstracts: abstracts)
          .toMap();
      return NIMResult.success(data: result);
    }
    return NIMResult.failure(message: messageUpload.errorDetails);
  }
}
