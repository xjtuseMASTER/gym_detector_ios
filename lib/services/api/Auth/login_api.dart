// 与登陆相关的api 管理

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/config.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/user_preferences_repository.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/user_repository.dart';
import 'package:gym_detector_ios/module/cache_module/user_preferences.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/services/utils/decode_response_data.dart';
import 'package:gym_detector_ios/services/utils/handle.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:netease_corekit_im/im_kit_client.dart';

class LoginApi {
  //保存用户信息
  static Future<void> saveUserData(Person person,UserPreferences preferences) async {
   //进行本地缓存
   await UserRepository.saveUser(person);  
   await UserPreferencesRepository.saveUserPreferences(preferences);
  }

  // 登录逻辑获取用户信息
  static Future<HandleError> fetchUserFromBackend(
      BuildContext context, Map<String, String> args) async {
    try {
      // 发送请求
      final response = await customHttpClient.post(
          Uri.parse('${Http.httphead}/auth/login'),
          body: jsonEncode(args));
      if (response.statusCode == 200) {
        // 请求成功
        //  提取 data 部分
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody);
        //保存登陆状态
        final person = Person(
            user_name: jsonResponse['data']['user_name'] ?? "input yōur user name", // 默认为空字符串
            selfInfo: jsonResponse['data']['selfIntro'] ?? "input yōur self intro", // 默认为空字符串
            gender: jsonResponse['data']['gender'] ?? "Man", // 默认为空字符串
            avatar: jsonResponse['data']['avatar'] ?? "", // 默认为空字符串
            user_id: jsonResponse['data']['user_id'] ?? "", // 默认为空字符串
            email: jsonResponse['data']['email'] ?? "", // 默认为空字符串
            password: jsonResponse['data']['password'] ?? "", // 默认为空字符串
            likes_num: jsonResponse['data']['likes_num'] ?? 0, // 默认为0
            birthday: jsonResponse['data']['birthday'] ?? "1999-01-01", // 默认为空字符串
            collects_num: jsonResponse['data']['collects_num'] ?? 0, // 默认为0
            followers_num: jsonResponse['data']['followers_num'] ?? 0 // 默认为0
            );
        //保存全局变量
        GlobalUser().setUser(person);
        GlobalUser().setToken(jsonResponse['data']['token']);
        //登陆云信账号
        var imInitHandle =
            await imInit(person.user_id.substring(0, 32), person.password);
        if (imInitHandle.isError) {
          return imInitHandle;
        }
        //获取用户偏好设置信息
        UserPreferences userPreferences =
            await fetchUserPreferencesFromBackend({
          'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
        });
        GlobalUserPreferences().setUserPreferences(userPreferences);
        //  缓存用户信息
        await saveUserData(person, userPreferences);
        return HandleError(code: response.statusCode, isError: false, data: {});
      } else {
        return HandleError(code: response.statusCode, isError: true, data: {});
      }
    } catch (e) {
      return HandleError(code: 100, isError: true, data: {});
    }
  }

  //获取用户偏好设置
  static Future<UserPreferences> fetchUserPreferencesFromBackend(
      Map<String, String> args) async {
    final response = await customHttpClient.get(
      Uri.parse('${Http.httphead}/user_preference/getpreferences').replace(
        queryParameters: args,
      ),
    );
    if (response.statusCode == 200) {
      final data = DecodeResponseData.transfer_to_Map(response);

      return UserPreferences.fromJson(data);
    } else {
      return UserPreferences(
          isInApp_Reminder: false,
          outInApp_Reminder: false,
          isLightTheme: true,
          isReleaseVisible: true,
          isCollectsVisible: true,
          isLikesVisible: true);
    }
  }

  /// init depends package for app
  static Future<HandleError> imInit(String account, String token) async {
    var options = await NIMSDKOptionsConfig.getSDKOptions(IMDemoConfig.AppKey);
    var success = await IMKitClient.init(IMDemoConfig.AppKey, options);
    if (success) {
      var value = await IMKitClient.loginIM(
          NIMLoginInfo(account: account, token: token));
      if (value) {
        return HandleError(code: 200, isError: false, data: {});
      } else {
        return HandleError(code: 98, isError: true, data: {});
      }
    } else {
      return HandleError(code: 99, isError: true, data: {});
    }
  }
}
