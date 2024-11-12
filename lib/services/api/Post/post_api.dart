// 关于帖子的接口

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/services/utils/decode_response_data.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';

class PostApi {
  // 首次获取新的帖子数据
  static Future<List<Map<String, dynamic>>> fetchMorePosts(Map<String,String> args) async {
   try {
    // 发送请求
    final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/post/stream').replace(
          queryParameters: args,
        ),
      ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      // 请求成功
      //  提取 data 部分
    final List<dynamic> postList = DecodeResponseData.transfer_to_Map(response);
    return postList.map((post) => post as Map<String, dynamic>).toList();
    } 
    else{
      return [];
    }
  } catch (e) {
    return[];
 
  }
}

  //从后端拿新数据
static Future<List<Map<String, dynamic>>> fetchNewPosts(BuildContext context,Map<String,String> args) async {
 try {
    // 发送请求
    final response = await customHttpClient.get(
      Uri.parse('${Http.httphead}/post/stream').replace(
        queryParameters:args,
      ),
    );

    if (response.statusCode == 200) {
      // 请求成功
      // 提取 data 部
      final List<dynamic> postList = DecodeResponseData.transfer_to_Map(response);
      return postList.map((post) => post as Map<String, dynamic>).toList();
    } else {
      HandleHttpError.handleErrorResponse(context, response.statusCode);
      return [];
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    // 返回一个空列表
    return [];
  }

}

}