//与注册相关的api
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_temp_user.dart';
import 'package:gym_detector_ios/services/utils/decode_response_data.dart';
import 'package:gym_detector_ios/services/utils/handle.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';

class SignupApi {

//对指定邮箱发送验证码
static Future<HandleError> submitEmail(BuildContext context,Map<String,String> args) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Submitting...');

    // 发送请求
    final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/auth/email').replace(
          queryParameters: args,
        ),
      );

    if (response.statusCode == 200) {
      //  提取 data 部分
      final data = DecodeResponseData.transfer_to_Map(response);
      //暂时存信息
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'submit Successfully');
      return HandleError(code:response.statusCode, isError:false, data: data);
    } else {
      LoadingDialog.hide(context);
      return HandleError(code:response.statusCode, isError:true, data: {});
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    LoadingDialog.hide(context);
    return HandleError(code:100, isError:true, data: {});
  }
}


//向后端发邮箱和密码进行注册
static Future<HandleError> submitRegister(BuildContext context,Map<String,String> args) async {
    try {
      final response = await customHttpClient.post(
        Uri.parse('${Http.httphead}/auth/register'),
        body: jsonEncode(args)
            
      );
      if (response.statusCode == 200) {
        //清除暂存信息
      GlobalTempUser().clearUser();
      return HandleError(code:response.statusCode, isError:false, data: {});

      } else {
        return HandleError(code:response.statusCode, isError:true, data: {});
      }
    } catch (e) {
      return HandleError(code:100, isError:true, data: {});
    }
  }

  
}