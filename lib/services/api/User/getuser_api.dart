//获取用户个人信息

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/contact/contact_provider.dart';

class GetuserApi {
  static bool isFollowed=false;
  // 异步获取数据
  static Future<Map<String,dynamic>> fetchUserData(Map<String,String> args) async {
    try {
      // 获取数据
      final Response = await customHttpClient.get(
          Uri.parse('${Http.httphead}/user/getuser').replace(queryParameters: args));
      final contact = getIt<ContactProvider>().getContact(args['user_id']!, needRefresh: true);
      if (Response.statusCode == 200) {
        final decodedBody = utf8.decode(Response.bodyBytes);
        final jsonResponse = json.decode(decodedBody);
        final person = Person(
            user_name: jsonResponse['data']['user_name']??"",
            selfInfo: jsonResponse['data']['selfInfo']??"",
            gender: jsonResponse['data']['gender']??"Man",
            avatar: jsonResponse['data']['avatar']??"",
            user_id: jsonResponse['data']['user_id']??"",
            password: "???",
            email: jsonResponse['data']['email']??"",
            likes_num: jsonResponse['data']['likes_num']?? 0,
            birthday: jsonResponse['data']['birthday']??"1999-01-01",
            collects_num: jsonResponse['data']['collects_num']?? 0,
            followers_num: jsonResponse['data']['followers_num']?? 0);
        isFollowed = jsonResponse['data']['isFollow'];
        
      return {'person': person, 'isFollowed': isFollowed, 'contact': contact};
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  //获取是否关注
  static bool getIsFollowed(){
    return isFollowed;
  }

   //确认关注
  static Future<void> comfirmOperateFollow(BuildContext context,Map<String,String> args,bool isFollowed) async {
    // 这里的Oncomfirm为代传入的向后端更新数据的接口

    try {
      // 显示加载对话框
      LoadingDialog.show(context, 'Operaing...');

      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse(isFollowed
                ? '${Http.httphead}/follower/unfollow'
                : '${Http.httphead}/follower/follow')
            .replace(
          queryParameters: args,
        ),
      );

      if (response.statusCode == 200) {
        // 请求成功
        //  提取 data 部分
        LoadingDialog.hide(context);
        CustomSnackBar.showSuccess(context, 'Operated Successfully');
      } else {
        // 隐藏加载对话框，显示错误提示框
        LoadingDialog.hide(context);
        HandleHttpError.handleErrorResponse(context, response.statusCode);
      }
    } catch (e) {
      // 捕获网络异常，如超时或其他错误
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }

}