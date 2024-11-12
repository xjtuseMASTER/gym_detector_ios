// 计算找回密码逻辑


import 'dart:convert';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_temp_user.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
class ResetpasswdApi {
  //修改密码
  static Future<void> submitResetPassword(BuildContext context,Map<String,String> args) async {
    try {
      final response = await customHttpClient.put(
        Uri.parse('${Http.httphead}/user/password'),
        body:jsonEncode(args)
            
      );
      if (response.statusCode == 200) {
        //清除暂存信息
        GlobalTempUser().clearUser();
       CustomSnackBar.showSuccess(context, "Reset Successfully! Please Login");
      } else {
        LoadingDialog.hide(context);
        HandleHttpError.handleErrorResponse(context, response.statusCode);
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }
}
