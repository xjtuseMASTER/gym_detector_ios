

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../user_preferences.dart'; // 确保导入了 UserPreferences 类

class UserPreferencesRepository {
  static const String boxName = 'userPreferences';

  // 初始化 Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserPreferencesAdapter()); // 注册适配器
    }
    await Hive.openBox<UserPreferences>(boxName);
  }

  // 获取用户偏好设置
  static UserPreferences? getUserPreferences() {
    final box = Hive.box<UserPreferences>(boxName);
    return box.get(0); // 假设只保存一个实例
  }

  // 保存用户偏好设置
  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    final box = Hive.box<UserPreferences>(boxName);
    await box.put(0, preferences); // 使用固定的 key 保存单一实例
  }

    //  清除用户设置
  static Future<void> clearUserPreferences() async {
    final box = Hive.box<UserPreferences>(boxName);
    await box.delete(0); // 删除固定的 key
  }
}