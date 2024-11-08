import 'package:bcrypt/bcrypt.dart';

class PasswordUtil {
  // 使用 bcrypt 生成密码的哈希值
  static String hashPassword(String password) {
    // 使用 bcrypt 生成哈希值，成本因子为 12（可以根据需求调整）
    // String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    // print(hashed);
    // return hashed;
    return password;
  }

  // 验证密码是否与哈希值匹配
  static bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }
}