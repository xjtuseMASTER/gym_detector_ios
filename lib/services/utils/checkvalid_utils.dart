// 检查字符合法性

class CheckvalidUtils {
  //邮箱是否合法
  static bool isEmailValid(String email) {
  String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // 正则表达式不允许空格
  RegExp regex = RegExp(emailPattern);

  return regex.hasMatch(email); // 如果匹配则返回 true，表示邮箱格式有效
}

  // 密码是否合法
  static bool isPasswordValid(String password) {
  // 检查密码是否包含空格，长度是否大于等于8
  if (password.contains(' ') || password.length < 8) {
    return false; // 格式不合理
  }
  return true; // 格式合理
}
}