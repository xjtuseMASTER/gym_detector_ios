// lib/module/cache_module/cache_utils/user_repository.dart

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../person.dart';

class UserRepository {
  static const String boxName = 'userBox';
  static const String loginTimeKey = 'loginTime';
  static const int loginValidDuration = 7 * 24 * 60 * 60 * 1000; // 7天的毫秒数

  // 初始化Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PersonAdapter());
    }
    await Hive.openBox<Person>(boxName);
    await Hive.openBox<int>('timeBox'); // 存储登录时间
  }

  // 保存用户信息，同时记录登录时间
  static Future<void> saveUser(Person user) async {
    final box = await Hive.box<Person>(boxName);
    final timeBox = await Hive.box<int>('timeBox');
    
    // 保存用户信息
    await box.put('currentUser', user);
    
    // 记录登录时间
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    await timeBox.put(loginTimeKey, currentTime);
  }

  // 检查登录是否过期
  static Future<bool> _isLoginExpired() async {
    final timeBox = await Hive.box<int>('timeBox');
    final loginTime = timeBox.get(loginTimeKey);
    
    if (loginTime == null) return true;
    
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - loginTime) > loginValidDuration;
  }

  // 清除所有登录信息
  static Future<void> _clearLoginData() async {
    final box = await Hive.box<Person>(boxName);
    final timeBox = await Hive.box<int>('timeBox');
    
    await box.delete('currentUser');
    await timeBox.delete(loginTimeKey);
  }

  // 获取当前用户信息（包含过期检查）
  static Future<Person?> getCurrentUser() async {
    // 首先检查是否过期
    if (await _isLoginExpired()) {
      await _clearLoginData();
      return null;
    }
    
    final box = await Hive.box<Person>(boxName);
    return box.get('currentUser');
  }

  // 检查是否有用户登录（包含过期检查）
  static Future<bool> isUserLoggedIn() async {
    // 首先检查是否过期
    if (await _isLoginExpired()) {
      await _clearLoginData();
      return false;
    }
    
    final box = await Hive.box<Person>(boxName);
    return box.containsKey('currentUser');
  }

  // 更新用户信息（可选：是否更新登录时间）
  static Future<void> updateUser(Person updatedUser, {bool refreshLoginTime = false}) async {
    final box = await Hive.box<Person>(boxName);
    await box.put('currentUser', updatedUser);
    
    if (refreshLoginTime) {
      final timeBox = await Hive.box<int>('timeBox');
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      await timeBox.put(loginTimeKey, currentTime);
    }
  }

  // 登出
  static Future<void> logout() async {
    await _clearLoginData();
  }

  // 获取剩余有效时间（毫秒）
  static Future<int> getRemainingValidTime() async {
    final timeBox = await Hive.box<int>('timeBox');
    final loginTime = timeBox.get(loginTimeKey);
    
    if (loginTime == null) return 0;
    
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int remainingTime = loginValidDuration - (currentTime - loginTime);
    
    return remainingTime > 0 ? remainingTime : 0;
  }

  // 获取登录过期时间（DateTime对象）
  static Future<DateTime?> getLoginExpireTime() async {
    final timeBox = await Hive.box<int>('timeBox');
    final loginTime = timeBox.get(loginTimeKey);
    
    if (loginTime == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(loginTime + loginValidDuration);
  }
}