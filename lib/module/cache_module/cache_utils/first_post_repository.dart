// 管理首页帖子的Hive盒子类

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../first_post.dart'; // 确保导入了 UserPreferences 类
class FirstPostRepository {
  static const String boxName = 'first_post_box';
  static late Box<FirstPost> _box;

  // 初始化Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(2)) {  // 确保注册适配器
      Hive.registerAdapter(FirstPostAdapter()); // 注册适配器
    }
    _box = await Hive.openBox<FirstPost>(boxName);  // 只打开一次盒子
  }

  // 获取首页帖子
  static Future<FirstPost?> getFirstPosts() async {
    return _box.get(0);  // 直接使用之前打开的盒子
  }

  // 添加首页帖子
  static Future<void> addFirstPost(FirstPost firstPost) async {
    await _box.put(0, firstPost);  // 直接使用之前打开的盒子
  }
   static Future<void> clear() async {
    final box = Hive.box<FirstPost>(boxName);
    await box.delete(0); // 删除固定的 key
  }
}