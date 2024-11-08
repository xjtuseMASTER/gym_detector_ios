//http 拦截器
// custom_http_client.dart
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:http/http.dart' as http;

class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // 添加全局的 headers
    // request.headers['Authorization'] = 'Bearer ${GlobalUser().getToken()}';
    request.headers['Content-Type'] = 'application/json';
    // 这里可以添加更多的全局请求头

    // 转发请求
    return _inner.send(request);
  }
}