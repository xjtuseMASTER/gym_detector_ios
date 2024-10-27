//管理主题状态的监听器
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';


class ThemeProvider with ChangeNotifier {
  bool _isLightTheme;

  ThemeProvider() : _isLightTheme = GlobalUserPreferences().getThemePreference() ?? true; // 初始化时根据用户偏好设置主题

  bool get isLightTheme => _isLightTheme;

  ThemeMode get currentTheme => _isLightTheme ? ThemeMode.light : ThemeMode.dark;

  void toggleTheme(bool isLight) {
    _isLightTheme = isLight;
    GlobalUserPreferences().userPreferences!.setisLightTheme(isLight); // 将更改后的主题偏好保存到全局用户偏好中
    notifyListeners();
  }
}