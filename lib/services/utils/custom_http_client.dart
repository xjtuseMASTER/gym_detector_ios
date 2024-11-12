//http 拦截器
// custom_http_client.dart
import 'dart:async';

import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:http/http.dart' as http;

class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
     const timeout = Duration(seconds: 30);
    // 添加全局的 headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Connection': 'close',
      'Authorization': 'Bearer ${GlobalUser().getToken()}',
      'token': 'dev',
      'Content-Type': 'application/json',
    });
    // 这里可以添加更多的全局请求头
// 使用 timeout
    try {
      return await _inner.send(request).timeout(timeout);
    } on TimeoutException catch (e) {
      throw Exception('请求超时: $e');
    }
  }
}
