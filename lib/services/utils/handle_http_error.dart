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
      case 100:
        errorMessage = 'Network error';
      case 429:
        errorMessage = 'Too many requests';
        break;
      case 519:
        errorMessage='Your account has been logged in elsewhere';
        break;
      case 400:
        errorMessage='The account or password is incorrect';
        break;
      case 99:
        errorMessage = 'IM login failed';
      case 98:
        errorMessage = 'IM client init failed';
      default:
        errorMessage = 'Unknown error';
    }
    CustomSnackBar.showFailure(context, errorMessage);
  }
}