import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';

class ChangeuserApi {

  
  //修改个人信息
 static Future<void> submitPersonInfo(BuildContext context, Map<String, String> args) async {
  LoadingDialog.show(context, 'Uploading...'); // 显示加载指示器

  try {
    // 发送 POST 请求到后端
    final response = await customHttpClient.post(
      Uri.parse('${Http.httphead}/user/change'),
      body: jsonEncode(args),
    );

    if (response.statusCode == 200) {
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Upload Successfully！');
    } else {
      LoadingDialog.hide(context);
      HandleHttpError.handleErrorResponse(context, response.statusCode);
    }
  } catch (e) {
    // 捕获网络异常并显示错误提示
    LoadingDialog.hide(context);
    CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
  }
}

  //修改头像
  static Future<void> uploadProfilePhoto(BuildContext context, String user_id, String secureurl) async {
    try {
      // 显示加载对话框

      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/user/changeprofile_photo').replace(
          queryParameters: {
            'user_id': user_id, // 传入 user_id 参数
            'sucure_url': secureurl
          },
        ),
      );

      if (response.statusCode == 200) {
        CustomSnackBar.showSuccess(context, 'Upload Successfully');
      } else {
        // 隐藏加载对话框，显示错误提示框
        LoadingDialog.hide(context);
        HandleHttpError.handleErrorResponse(context, response.statusCode);
      }
    } catch (e) {
      // 捕获网络异常，如超时或其他错误
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot upload data');
    }
  }

}