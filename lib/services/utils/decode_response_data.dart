// 将response中的data提取出为json对象返回

import 'dart:convert';
import 'package:http/http.dart' as http;

class DecodeResponseData {
  static transfer_to_Map(http.Response response){
    try {
      final decodedBody = utf8.decode(response.bodyBytes); 
      final jsonResponse=json.decode(decodedBody);
      return jsonResponse['data'];
    } catch (e) {
      print("Decoding error: $e");
      return {};
    }
  }
}