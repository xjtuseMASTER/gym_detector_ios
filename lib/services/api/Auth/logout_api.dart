//登出逻辑

import 'dart:convert';

import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/services/utils/handle.dart';
import 'package:gym_detector_ios/widgets/http.dart';

class LogoutApi {
 // 登录逻辑获取用户信息
  static Future<HandleError> Userlogout(Map<String,String> args) async{
    try {
      // 发送请求
      final response = await customHttpClient.post(
          Uri.parse('${Http.httphead}/auth/logout'),
          body: jsonEncode(args));
      if (response.statusCode == 200) {
        return HandleError(code: response.statusCode, isError: false, data: {});
      } else {
        return HandleError(code: response.statusCode, isError: true, data: {});
      }
    } catch (e) {
      return HandleError(code: 100, isError: true, data: {});
    }
  }

}