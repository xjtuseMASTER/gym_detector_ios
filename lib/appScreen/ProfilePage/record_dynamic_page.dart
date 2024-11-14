//点赞，收藏，发布的记录界面
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/used_post_gridview.dart';
 import 'package:http/http.dart' as http;

class RecordDynamicPage extends StatefulWidget{
  final int index;//决定显示哪个页面
  final String title;
  final Person getperson;// 目标访问用户
  final isOneself;//是否是本人
  final Map<String,dynamic> isVisble;
  final String name;
  RecordDynamicPage({required this.index,required this.title,required this.getperson,required this.isOneself,required this.isVisble,required this.name});
  _RecordDynamicPageState createState()=>_RecordDynamicPageState();

}
class _RecordDynamicPageState extends State<RecordDynamicPage>{

    //拿取数据之后先对权限进行检查若用户设置不可见则无法显示
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
            }, 
          icon: Icon(Icons.arrow_back)),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true
      ),
      body: 
      Stack(
      children: [  
        //根据偏好设置显不显示
      widget.isVisble[widget.name]?
      UsedPostGridview(person: widget.getperson,fetchMorePosts: fetchMorePosts)
      :const Center(
      child: Text(
        "This user is not open to you",
        style: TextStyle(
          color: Colors.purple, // 紫色
          fontSize: 24,         // 较大的字体
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      )
      ]
      )
    );
  }
  //分页从后端拿数据
  Future<List<Map<String, dynamic>>> fetchMorePosts( String user_id,int Pagenumber) async {
  final responseJson;
  if(widget.index==0){
    //拿去喜欢的数据
    responseJson = await customHttpClient.get(Uri.parse('${Http.httphead}/post_like/see_like').replace(queryParameters: {
            'userId': user_id,
            'pageNumber': Pagenumber.toString(),            
          }),
        ).timeout(const Duration(seconds: 30));
  }
  else if(widget.index==1)
  {
    //拿去发布数据
    responseJson = await customHttpClient.get(Uri.parse('${Http.httphead}/post/mypost').replace(queryParameters: {
            'userId': user_id,
            'pageNumber': Pagenumber.toString(),            
          }),
        ).timeout(const Duration(seconds: 30));
  }  
  else{
    //拿去收藏数据
    responseJson = await customHttpClient.get(Uri.parse('${Http.httphead}/post_collect/mycollect').replace(queryParameters: {
            'userId': user_id,
            'pageNumber': Pagenumber.toString(),            
          }),
        ).timeout(const Duration(seconds: 30));
  }
  
  // 检查请求是否成功
  if (responseJson.statusCode==200) {
    final decodedBody = utf8.decode(responseJson.bodyBytes); 
    final jsonResponse = json.decode(decodedBody);
    // 获取 postList
    final List<dynamic> postList = jsonResponse['data'];
    
    // 转换为 List<Map<String, dynamic>>
    return postList.map((post) => post as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load posts');
  }

}

}