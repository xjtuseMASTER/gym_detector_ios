import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/others_profile_page.dart';
import 'package:gym_detector_ios/appScreen/HomePage/widgets/comment_selection.dart';
import 'package:gym_detector_ios/module/person.dart';

class DetailPage extends StatefulWidget {
  // final Map<String, dynamic> post;
  // DetailPage({required this.post});
  final Map<String, dynamic> post={
    'author':Person.personGenerator(),//帖子的作者
    'liked':1200,//该篇帖子的点赞数
    'likes':false,//是否点赞该帖子
    'images':['assets/dynamic_images/sample1.jpg','assets/dynamic_images/sample2.jpg','assets/dynamic_images/sample3.jpg'],
    'currentImageIndex':0,//当前显示图片
    'title':'Welcome to NewYork!',
    'content':'使用PageView.builder实现图片左右滑动，结合Stack和Positioned来显示图片切换时的小红点指示器。',
    'commentsCount':890,
    'comments':[{
      'author':Person.personGenerator(),//评论的作者
      'content':'what a beautiful',
      'time':'2024-10-1',
      'replies':
      [{
      'author':Person.personGenerator(),//评论的作者
      'content':'what a shit',
      'time':'2024-10-1'}]
      },
      {
      'author':Person.personGenerator(),//评论的作者
      'content':'what a shit',
      'time':'2024-10-1',
      'replies':[]
    
      },
      {
     'author':Person.personGenerator(),//评论的作者
      'content':'what a big',
      'time':'2024-10-1',
      'replies':[]
      },
      ]
  };
  final String  postId;//帖子Id
  final String  autherId;//作者Id
  DetailPage({required this.postId, required this.autherId});
 @override
  _DetailPage createState() => _DetailPage();
}
class _DetailPage extends State<DetailPage>{
bool isCollect = false; // 收藏状态
bool isFavorite=false;//点赞状态
double collect_iconScale = 1.3; // 收藏按钮初始缩放比例
double favorite_iconScale = 1.3;  // 点赞按钮初始缩放比例
int currentImageIndex=0;
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 220, 179, 235), // 白色背景
      elevation: 0, // 取消阴影
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black), // 返回按钮
        onPressed: () {
          Navigator.pop(context); // 返回首页
        },
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              // 导航到作者主页
              Navigator.push(context, 
              MaterialPageRoute(
                builder:  (context)=>OthersProfilePage(person: widget.post['author'])
              )
              );
            },
            child:  CircleAvatar(
            backgroundImage: AssetImage(widget.post['author'].profile_photo), // 帖子作者头像
            radius: 20,
          ),
          ),
          SizedBox(width: 10),
          Text(
            widget.post['author'].name, 
          style: const TextStyle(
            color: Colors.black,
          fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,)), // 帖子作者呢称
          Spacer(),
          TweenAnimationBuilder(
              tween: Tween<double>(begin: 1.3, end: collect_iconScale), // 动画的起点和终点
              duration: Duration(milliseconds: 200), // 动画时长
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale, // 根据 scale 调整大小
                  child: IconButton(
                    icon: Icon(
                      isCollect ? Icons.star : Icons.star_border, // 根据状态显示图标
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      setState(() {
                        isCollect = !isCollect; // 切换收藏状态
                        collect_iconScale = 1.7; // 设置放大效果
                      });
                      // 动画结束后将图标缩回原始大小
                      Future.delayed(Duration(milliseconds: 200), () {
                        setState(() {
                         collect_iconScale= 1.3; // 缩回原始大小
                        });
                      });
                    },
                  ),
                );
              },
            ),
      
        ],
      ),
    ),
    body: Column(
      children: [
        // 帖子图片组，使用PageView显示多张图片
        Expanded(
          flex: 7, // 占据屏幕的上部分
          child: Stack(
            children: [
              PageView.builder(
                itemCount: widget.post['images'].length,
                itemBuilder: (context, index) {
                  return Image.asset(widget.post['images'][index], fit: BoxFit.cover);
                },
                onPageChanged: (index) {
                  setState(() {
                    currentImageIndex=index;
                  });
                  // 切换图片时处理小红点显示
                },
              ),
              // 小红点指示器
              Positioned(
                bottom: 10,
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: Row(
                  children: List.generate(widget.post['images'].length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == currentImageIndex
                            ? Colors.white
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // 包裹帖子标题、配文和评论区为可滑动区域
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 帖子标题和配文
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(widget.post['content'], style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                const Text(
                  'Comments',
                  style: TextStyle(
                     color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // 评论区
                CommentSection(post: widget.post)
              ],
            ),
          ),
        ),

        // 底部评论输入框和按钮
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          decoration: BoxDecoration(
            color:const Color.fromARGB(255, 220, 179, 235),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.grey.shade300,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
  flex: 5,
  child: GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // 确保键盘弹出时 BottomSheet 可以随之调整
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // 自动适配键盘高度
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                                    autofocus: true, // 自动弹出键盘
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    // 发送评论逻辑
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.grey.shade300,             
                        ),   
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Add a comment...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
                TweenAnimationBuilder(
                tween: Tween<double>(begin: 1.3, end: favorite_iconScale), // 动画的起点和终点
                duration: Duration(milliseconds: 200), // 动画时长
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale, // 根据 scale 调整大小
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border, // 根据状态显示图标
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite; // 切换点赞状态
                          favorite_iconScale = 1.7; // 设置放大效果
                        });
                        // 动画结束后将图标缩回原始大小
                        Future.delayed(Duration(milliseconds: 200), () {
                          setState(() {
                            favorite_iconScale = 1.3; // 缩回原始大小
                          });
                        });
                      },
                    ),
                  );
                },
              ),
              Text(isFavorite?widget.post['liked'].toString():(widget.post['liked']+1).toString()),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  // 显示评论数逻辑
                },
              ),
              Text(widget.post['commentsCount'].toString())
            ],
          ),
        ),
      ],
    ),
  );
}
}