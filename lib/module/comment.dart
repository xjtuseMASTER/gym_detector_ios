//评论对象
import 'package:gym_detector_ios/module/person.dart';

class Comment {
  String? commentId;//评论id
  int? label;//评论登级：1:对帖子评论 2:对直接对帖子评论的回复
  Person? author;
  String? content;//评论内容
  String? time;//评论时间
  Person? replyTo;//回复对象：label =1:直接回复帖子作者，label =2:回复具体哪条评论
  List<Comment>? replies;//这条评论的回复表
  // ignore: non_constant_identifier_names
  int? likescont;//评论点赞数


  Comment({
    required this.commentId,
    required this.label,
    required this.author,
    required this.content,
    required this.time,
    required this.replyTo,
    required this.replies,
    required this.likescont
  });
  
}