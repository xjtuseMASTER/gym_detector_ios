import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/create_post_page.dart';
import 'package:gym_detector_ios/appScreen/HomePage/feedback_page.dart';
import 'package:gym_detector_ios/appScreen/HomePage/widgets/square_post_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/profile_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/account_security_page.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/used_post_gridview.dart';
 import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  List<Map<String, dynamic>> initialPosts;
 _HomePageState createState()=>_HomePageState();
 HomePage({required this.initialPosts});
}
class _HomePageState extends State<HomePage>{
  final Person user =GlobalUser().getUser()!;

  // 模拟动态数据
  final List<Map<String, dynamic>> posts = [
    {
      'image': 'assets/dynamic_images/sample1.jpg',
      'text': '171 50kg 不计成本的修炼自己！',
      'views': 123,
      'likes': 45
    },
    {
      'image': 'assets/dynamic_images/sample2.jpg',
      'text': '小猫',
      'views': 6220,
      'likes': 89
    },
    {
      'image': 'assets/dynamic_images/sample3.jpg',
      'text': '秀出好身材',
      'views': 5310,
      'likes': 105
    },
    {
      'image': 'assets/dynamic_images/sample4.jpg',
      'text': '普拉提时刻！',
      'views': 4310,
      'likes': 105
    },
    {
      'image': 'assets/dynamic_images/sample5.jpg',
      'text': '带我出门应该会有安全感吧',
      'views': 3310,
      'likes': 1305
    },
    {
      'image': 'assets/dynamic_images/sample6.jpg',
      'text': '你不发怎么回你信息',
      'views': 11310,
      'likes': 1205
    },
    {
      'image': 'assets/dynamic_images/sample7.jpg',
      'text': '也许当年冬天她很爱你,但现在是2024年了',
      'views': 1310,
      'likes': 1205
    },
    {
      'image': 'assets/dynamic_images/sample8.jpg',
      'text': '身高156，这是我健身四五年的身材！',
      'views': 3100,
      'likes': 1005
    },
    {
      'image': 'assets/dynamic_images/sample9.jpg',
      'text': '身高156，这是我健身四五年的身材！',
      'views': 3100,
      'likes': 1005
    },
     {
      'image': 'assets/dynamic_images/sample10.jpg',
      'text': '今天练习了引体向上',
      'views': 6220,
      'likes': 89
    },
    {
      'image': 'assets/dynamic_images/sample11.jpg',
      'text': '完美的俯卧撑！',
      'views': 5310,
      'likes': 105
    },
    {
      'image': 'assets/dynamic_images/sample12.jpg',
      'text': '借着月光思念你！',
      'views': 4310,
      'likes': 105
    },
  ];
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profile_photo)
              ),
              onPressed: () {
                // 点击头像，打开侧边栏
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Show Yourself!',
          style: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.headset_mic, color: Color(0xFF755DC1)),
            onPressed: () {
              // 点击反馈按钮
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> FeedbackPage())
               );
            },
          ),
        ],
      ),
      drawer: Container(
      width: 200,
      child: Drawer(
         child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(user.profile_photo), // 替换为用户头像
                    fit: BoxFit.cover, // 使图片填充整个区域
                  ),
                  color: Colors.white, // 叠加的白色背景
              ),
              child: const Text(
                ''
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person,color: Colors.grey),
              title: const Text(
                'Personal Homepage',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(selected: 0)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings,color: Colors.grey),
              title: const Text(
                'Settings',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(selected: 2)));
              },
            ),
             ListTile(
              leading: const Icon(Icons.logout,color: Colors.grey),
              title: const Text(
                'Account',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AccountSecurityPage()));
              },
            ),
             ListTile(
              leading: const Icon(Icons.scanner_rounded,color: Colors.grey),
              title: const Text(
                'Scanner',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {},
            ),
             ListTile(
              leading: const Icon(Icons.dynamic_feed,color: Colors.grey),
              title: const Text(
                'Personal dynamics',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.question_mark_outlined,color: Colors.grey),
              title: const Text(
                'About us',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {},
            ),
          ]
        )
       ),
      ),
      body: 
      Stack(
      children: [  
      posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SquarePostView(initialPosts: widget.initialPosts, person: user,fetchMorePosts: fetchMorePosts,fetchNewPosts: fetchNewPosts,),//瀑布流展示widget
            Positioned( //右下角放置用户发布动态按钮
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor:  Color.fromARGB(255, 142, 127, 192),
                onPressed: (){
                  Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePostPage(), 
                            ),
                 );
                },
                child: Icon(Icons.add),                
              )

            )
      ]
      )
    );
  }
  //分页从后端拿数据
  Future<List<Map<String, dynamic>>> fetchMorePosts( String user_id,int Pagenumber) async {
  // 模拟从后端获取 JSON 响应，实际上你会用 http.get 等获取真实数据
  final responseJson = await http.get(Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/post/stream'));
  // 检查请求是否成功
  if (responseJson.statusCode==200) {
    final jsonResponse=json.decode(responseJson.body);
    // 获取 postList
    final List<dynamic> postList = jsonResponse['data']['postList'];
    
    // 转换为 List<Map<String, dynamic>>
    return postList.map((post) => post as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load posts');
  }

}

//刷新数据
  Future<List<Map<String, dynamic>>> fetchNewPosts() async {
  // 模拟从后端获取 JSON 响应，实际上你会用 http.get 等获取真实数据
  final responseJson = await http.get(Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/post/stream'));
  // 检查请求是否成功
  if (responseJson.statusCode==200) {
    final jsonResponse=json.decode(responseJson.body);
    // 获取 postList
    final List<dynamic> postList = jsonResponse['data']['postList'];
    
    // 转换为 List<Map<String, dynamic>>
    return postList.map((post) => post as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load posts');
  }

}



}