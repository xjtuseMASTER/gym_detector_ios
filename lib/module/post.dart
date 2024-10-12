// 帖子对象

import 'package:gym_detector_ios/module/comment.dart';
import 'package:gym_detector_ios/module/person.dart';

class Post {
  
  String? postId;//帖子id
  Person? author; //帖子作者
  int? likescount;//帖子点赞数
  bool? isLike;//用户是否喜欢这条视频
  List<String>? images;//帖子的照片组
  int ?currentImageIndex;//当前展示哪张照片
  String? title;//帖子标题
  String? content;//内容
  int? commentsCount;//评论数
  List<Comment>? comments;//评论表
  String? time;//发表时间

  
  Post({
    required this.postId,
    required this.author,
    required this.likescount,
    required this.isLike,
    required this.images,
    required this.currentImageIndex,
    required this.title,
    required this.content,
    required this.commentsCount,
    required this.comments,
    required this.time

    });

  //  'liked':1200,//该篇帖子的点赞数
  //   'likes':false,//是否点赞该帖子
  //   'images':['assets/dynamic_images/sample1.jpg','assets/dynamic_images/sample2.jpg','assets/dynamic_images/sample3.jpg'],
  //   'currentImageIndex':0,//当前显示图片
  //   'title':'Welcome to NewYork!',
  //   'content':'使用PageView.builder实现图片左右滑动，结合Stack和Positioned来显示图片切换时的小红点指示器。',
  //   'commentsCount':890,
  //   'comments':[{
  //     'author':Person.personGenerator(),//评论的作者
  //     'content':'what a beautiful',
  //     'time':'2024-10-1',
  //     'replies':
  //     [{
  //     'author':Person.personGenerator(),//评论的作者
  //     'content':'what a shit',
  //     'time':'2024-10-1'}]
  //     },
  //     {
  //     'author':Person.personGenerator(),//评论的作者
  //     'content':'what a shit',
  //     'time':'2024-10-1',
  //     'replies':[]
    
  //     },
  //     {
  //    'author':Person.personGenerator(),//评论的作者
  //     'content':'what a big',
  //     'time':'2024-10-1',
  //     'replies':[]
  //     },
  //     ]




}