//全局用户类/只能实例化一次
//每次登陆后存储，登出时清除

import 'package:gym_detector_ios/module/cache_module/person.dart';

class GlobalUser {
  static final GlobalUser _instance = GlobalUser._internal(); // 静态实例

  factory GlobalUser() {
    return _instance; // 工厂构造函数，返回单例实例
  }

  GlobalUser._internal(); //阻止外部创建新实例

  Person? user; // 可变的用户对象
  String token='';//jwt

  // 设置用户信息
  void setUser(Person person) {
    user = person;
  }
  void setToken(String token){
    this.token=token;
  }

  // 获取用户信息
  Person? getUser() {
    return user;
  }
  //获取token
  String? getToken(){
    return token;
  }

  // 清除用户信息
  void clearUser() {
    user = null;
  }
}