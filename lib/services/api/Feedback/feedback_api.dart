//用户反馈管理

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';

class FeedbackApi {
  //提交反馈
  static Future<void> handleFeedbackSubmission(BuildContext context,Map<String,String> args) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Submitting...');

    // 发送请求
    final response = await customHttpClient.get(Uri.parse('${Http.httphead}/user_feedback/feedback').replace(
      queryParameters: args
    ));
    if (response.statusCode == 200) {
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Submitted Successfully, Thank you!');
    } else {
      LoadingDialog.hide(context);
      HandleHttpError.handleErrorResponse(context, response.statusCode);
    }
  } catch (e) {
    LoadingDialog.hide(context);
    CustomSnackBar.showFailure(context,'Network Error: Cannot fetch data');
  }
}
}