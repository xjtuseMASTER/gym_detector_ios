// 首次拿数据进行缓存

import 'package:hive/hive.dart';
part 'first_post.g.dart';  // 这行必须在文件开头

@HiveType(typeId: 2)
class FirstPost extends HiveObject{

  @HiveField(0)
  final List<Map<String, dynamic>> data;
  
  FirstPost({required this.data});
  
}