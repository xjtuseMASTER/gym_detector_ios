

import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtil {
  // 使用 SHA-256 生成密码的哈希值
  static String hashPassword(String password) {
    // 将密码转换为字节数组
    var bytes = utf8.encode(password);
    // 使用 SHA-256 计算哈希值
    var digest = sha256.convert(bytes);
    print(digest.toString());
    // 返回哈希值的十六进制字符串表示
    return digest.toString();
  }
}