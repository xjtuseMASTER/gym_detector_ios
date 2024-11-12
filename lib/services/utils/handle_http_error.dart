//处理正常的http错误状态码

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';

class HandleHttpError {
  static void handleErrorResponse(BuildContext context, int statusCode) {
    String errorMessage;
    switch (statusCode) {
      case 404:
        errorMessage = 'Resource not found';
        break;
      case 500:
        errorMessage = 'Server error';
        break;
      case 403:
        errorMessage = 'Permission denied';
        break;
      default:
        errorMessage = 'Unknown error';
    }
    CustomSnackBar.showFailure(context, errorMessage);
  }
}