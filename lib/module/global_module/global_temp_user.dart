//注册，找回密码存储暂时信息的全局类

class GlobalTempUser {
  static final GlobalTempUser _instance = GlobalTempUser._internal(); // 静态实例

  factory GlobalTempUser() {
    return _instance; // 工厂构造函数，返回单例实例
  }

  GlobalTempUser._internal(); //阻止外部创建新实例

   String? email; // 邮箱
  String? password; //密码
  String? authcode;//验证码

  // 设置信息
  void setEmail(String  email) {
    this.email= email;
  }
  void setPassword(String  password) {
    this.password= password;
  }
  void setAuthcode(String  authcode) {
    this.authcode= authcode;
  }
  // 清除用户信息
  void clearUser() {
    email = null;
    password=null;
    authcode=null;
  }
}