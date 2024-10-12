//点赞，收藏，发布的记录界面
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/post_gridview.dart';

class RecordDynamicPage extends StatefulWidget{
  final int index;//决定显示哪个页面
  final String title;
  final Person getperson;// 目标访问用户
  RecordDynamicPage({required this.index,required this.title,required this.getperson});
  _RecordDynamicPageState createState()=>_RecordDynamicPageState();

}
class _RecordDynamicPageState extends State<RecordDynamicPage>{

    //拿取数据之后先对权限进行检查若用户设置不可见则无法显示
   // 模拟动态数据
  final List<Map<String, dynamic>> posts = [
    {
      'image': 'assets/dynamic_images/sample9.jpg',
      'text': '171 50kg 不计成本的修炼自己！',
      'views': 123,
      'likes': 45
    },
    {
      'image': 'assets/dynamic_images/sample10.jpg',
      'text': '小猫',
      'views': 6220,
      'likes': 89
    },
    {
      'image': 'assets/dynamic_images/sample11.jpg',
      'text': '秀出好身材',
      'views': 5310,
      'likes': 105
    },
    {
      'image': 'assets/dynamic_images/sample12.jpg',
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
      'image': 'assets/dynamic_images/sample1.jpg',
      'text': '身高156，这是我健身四五年的身材！',
      'views': 3100,
      'likes': 1005
    },
     {
      'image': 'assets/dynamic_images/sample2.jpg',
      'text': '今天练习了引体向上',
      'views': 6220,
      'likes': 89
    },
    {
      'image': 'assets/dynamic_images/sample3.jpg',
      'text': '完美的俯卧撑！',
      'views': 5310,
      'likes': 105
    },
    {
      'image': 'assets/dynamic_images/sample4.jpg',
      'text': '借着月光思念你！',
      'views': 4310,
      'likes': 105
    },
  ];
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
      posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PostGridview(posts: posts),
      ]
      )
    );
  }


}