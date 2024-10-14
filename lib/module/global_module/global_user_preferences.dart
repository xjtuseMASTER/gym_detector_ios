//全局用户偏好设置只能实例化一次
//每次登陆后存储，登出时清除
import 'package:gym_detector_ios/module/user_preferences.dart';

class GlobalUserPreferences {
  static final GlobalUserPreferences _instance = GlobalUserPreferences._internal(); // 静态实例

  factory GlobalUserPreferences() {
    return _instance; // 工厂构造函数，返回单例实例
  }

  GlobalUserPreferences._internal(); //阻止外部创建新实例

  UserPreferences? userPreferences; // 可变的用户偏好设置对象

  // 设置用户信息
  void setUserPreferences(UserPreferences userpreferences) {
    userPreferences = userpreferences;
  }

  // 获取用户信息
  UserPreferences? getUserPreferences() {
    return userPreferences;
  }

  // 清除用户信息
  void clearUserPreferences() {
    userPreferences = null;
  }
}