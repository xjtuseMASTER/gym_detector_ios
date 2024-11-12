// 与登陆相关的api 管理

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';
import 'package:gym_detector_ios/services/utils/decode_response_data.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi {
  
  
  //保存用户信息

static Future<void> saveUserData(Person person) async {
  final prefs = await SharedPreferences.getInstance();
  //保存登录者id
  await prefs.setString('user_id', person.user_id);
  //保存登陆邮箱
  await prefs.setString('user_email', person.email);
  // 保存登录时间
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt('login_time', currentTime);
  }

 // 登录逻辑获取用户信息
static Future<void> fetchUserFromBackend(BuildContext context,Map<String,String> args) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Logining...');
    // 发送请求
    final response = await customHttpClient.post(
        Uri.parse('${Http.httphead}/auth/login'),
        body: jsonEncode(args)
      );
    if (response.statusCode == 200) {
      // 请求成功
      //  提取 data 部分
      final decodedBody = utf8.decode(response.bodyBytes); 
      final jsonResponse=json.decode(decodedBody);
      //保存登陆状态
     final person = Person(
      user_name: jsonResponse['data']['user_name'] ?? "", // 默认为空字符串
      selfInfo: jsonResponse['data']['selfIntro'] ?? "", // 默认为空字符串
      gender: jsonResponse['data']['gender'] ?? "", // 默认为空字符串
      avatar: jsonResponse['data']['avatar'] ?? "", // 默认为空字符串
      user_id: jsonResponse['data']['user_id'] ?? "", // 默认为空字符串
      email: jsonResponse['data']['email'] ?? "", // 默认为空字符串
      password: jsonResponse['data']['password'] ?? "", // 默认为空字符串
      likes_num: jsonResponse['data']['likes_num'] ?? 0, // 默认为0
      birthday: jsonResponse['data']['birthday'] ?? "", // 默认为空字符串
      collects_num: jsonResponse['data']['collects_num'] ?? 0, // 默认为0
      followers_num: jsonResponse['data']['followers_num'] ?? 0 // 默认为0
    );
      saveUserData(person);
      //保存全局变量
      GlobalUser().setUser(person);
      GlobalUser().setToken(jsonResponse['data']['token']);
      //获取用户偏好设置信息
      UserPreferences userPreferences= await fetchUserPreferencesFromBackend({
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
          });
      GlobalUserPreferences().setUserPreferences(userPreferences);
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Login Successfully');
    } else {
      LoadingDialog.hide(context);
      HandleHttpError.handleErrorResponse(context,response.statusCode);
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    LoadingDialog.hide(context);
     CustomSnackBar.showFailure(context,'Network Error: Cannot fetch data');
  }
}

   
//获取用户偏好设置
static Future<UserPreferences> fetchUserPreferencesFromBackend(Map<String,String> args) async{
  final response= await customHttpClient.get(Uri.parse('${Http.httphead}/user_preference/getpreferences').replace(
          queryParameters: args,
        ),);
  if(response.statusCode==200){
    
    final data=DecodeResponseData.transfer_to_Map(response);
    
    return UserPreferences.fromJson(data);
  }
  else{
       return UserPreferences(isInApp_Reminder: false, outInApp_Reminder: false, isLightTheme: true, isReleaseVisible: true, isCollectsVisible: true, isLikesVisible: true);
  }

  }

}