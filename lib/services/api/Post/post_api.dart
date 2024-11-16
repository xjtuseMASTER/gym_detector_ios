// 关于帖子的接口

import 'dart:convert';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/AppPage/upload_page.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/services/utils/decode_response_data.dart';
import 'package:gym_detector_ios/services/utils/handle.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:image_picker/image_picker.dart';

class PostApi {
  // 首次获取新的帖子数据
  static Future<HandleError> fetchMorePosts(Map<String, String> args) async {
  try {
    final response = await customHttpClient.get(
      Uri.parse('${Http.httphead}/post/stream').replace(
        queryParameters: args,
      ),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      // Extract the data part
      final List<dynamic> postList = DecodeResponseData.transfer_to_Map(response);
      final post=postList.map((post) => post as Map<String, dynamic>).toList();
      return HandleError(code: 200, isError: false, data: {'data':post,'msg':"No one's posted yet. Grab the first！"});
    } else {
      return HandleError(code: response.statusCode, isError: true, data: {'data':[],'msg':"Network Error"});
      
    }
  } catch (e) {
    return HandleError(code: 100, isError: true, data: {'data':[],'msg':"Network Error"});
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

//点赞和取消点赞
  static Future<void> operateFavorite(BuildContext context,bool isFavorite,Map<String,String> args) async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse(isFavorite
                ? '${Http.httphead}/post_like/unlike'
                : '${Http.httphead}/post_like/like')
            .replace(
          queryParameters:args,
        ),
      );
      if (response.statusCode == 200) {
      } else {
       HandleHttpError.handleErrorResponse(context, response.statusCode);
      }
    } catch (e) {
      // 捕获网络异常，如超时或其他错误
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }


  //收藏和取消收藏的操作
  static Future<void> operateCollect(BuildContext context,bool isFavorite,Map<String,String> args) async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse(isFavorite
                ? '${Http.httphead}/post_collect/uncollect'
                : '${Http.httphead}/post_collect/collect')
            .replace(
          queryParameters:args,
        ),
      );
      if (response.statusCode == 200) {
      } else {
       HandleHttpError.handleErrorResponse(context, response.statusCode);
    }
    } catch (e) {
      // 捕获网络异常，如超时或其他错误
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }


  //获取帖子数据
  static Future<Map<String, dynamic>> fetchPostData(Map<String,String> args) async {
    try {
      final response = await customHttpClient.get(
        Uri.parse(
                '${Http.httphead}/post/details')
            .replace(
          queryParameters:args,
        ),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse = json.decode(decodedBody);
        return jsonResponse['data'] ?? {}; // 返回数据
      } else {
        throw Exception('Failed to fetch post data');
      }
    } catch (e) {
      print('Error: $e');
      return {}; // 返回空数据以避免错误
    }
  } 
  // 获取评论数据
  static Future<List<Map<String, dynamic>>> fetchCommentData(Map<String,String> args) async {
    try {
      final response = await customHttpClient.get(
        Uri.parse(
                '${Http.httphead}/comment/commentdetail')
            .replace(
          queryParameters:args,
        ),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse = json.decode(decodedBody);
        return List<Map<String, dynamic>>.from(
            jsonResponse['data'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  //对帖子评论
  static Future<String> replyToPost(BuildContext context,Map<String, dynamic> body) async {
    LoadingDialog.show(context, 'Replying...'); // 显示加载指示器

    try {
      // 发送 POST 请求到后端
      final response = await customHttpClient.post(
        Uri.parse(
            '${Http.httphead}/comment/comment'),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse=json.decode(decodedBody);
        CustomSnackBar.showSuccess(context, "reply successfully!");
        return jsonResponse['data']['comment_id'];
      } else {
        LoadingDialog.hide(context);
        HandleHttpError.handleErrorResponse(context, response.statusCode);
        return '';
      }
    } catch (e) {
      // 捕获网络异常并显示错误提示
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
      return '';
    }
  }
  //回复评论
  static Future<String> replyToComment(BuildContext context, Map<String, dynamic> body) async {
    LoadingDialog.show(context, 'Replying...'); // 显示加载指示器

    try {
      // 发送 POST 请求到后端
      final response = await customHttpClient.post(
        Uri.parse(
            '${Http.httphead}/comment/sub_comment'),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse=json.decode(decodedBody);
        CustomSnackBar.showSuccess(context, "reply successfully!");
        return jsonResponse['data']['comment_id'];
      } else {

        LoadingDialog.hide(context);
        HandleHttpError.handleErrorResponse(context, response.statusCode);
        return '';
      }
    } catch (e) {
      // 捕获网络异常并显示错误提示
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
      return '';
    }
  }
  //获取指定用户的历史上传/收藏/点赞数据
  static Future<List<Map<String, dynamic>>> fetchUsedPosts(int index,Map<String,String> args) async {
  final responseJson;
  if(index==0){
    //拿去喜欢的数据
    responseJson = await customHttpClient.get(Uri.parse('${Http.httphead}/post_like/see_like').replace(queryParameters:args)
        ).timeout(const Duration(seconds: 30));
  }
  else if(index==1)
  {
    //拿去发布数据
    responseJson = await customHttpClient.get(Uri.parse('${Http.httphead}/post/mypost').replace(queryParameters:args),
        ).timeout(const Duration(seconds: 30));
  }  
  else{
    //拿去收藏数据
    responseJson = await customHttpClient.get(Uri.parse('${Http.httphead}/post_collect/mycollect').replace(queryParameters:args),
        ).timeout(const Duration(seconds: 30));
  }
  // 检查请求是否成功
  if (responseJson.statusCode==200) {
    final decodedBody = utf8.decode(responseJson.bodyBytes); 
    final jsonResponse = json.decode(decodedBody);
    // 获取 postList
    final List<dynamic> postList = jsonResponse['data'];
    // 转换为 List<Map<String, dynamic>>
    return postList.map((post) => post as Map<String, dynamic>).toList();
  } else {
    return [];
  }

}


}
