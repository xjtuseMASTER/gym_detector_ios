// 瀑布流图像展示widget
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/postdetail_page.dart';

class PostGridview extends StatefulWidget{
  final List<Map<String,dynamic>> posts;

  PostGridview({required this.posts});

  _PostGridviewState createState()=>_PostGridviewState();

}
class _PostGridviewState extends State<PostGridview> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 一共两列
        crossAxisSpacing: 6.0,
        mainAxisSpacing: 6.0,
        childAspectRatio: 0.68, // 长宽比为0.68
      ),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index]; // Create a variable for easier reference
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ), // 修剪图片为圆角半径10
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(), // 传递post数据到详情页
                    ),
                  );
                },
                child: Flexible(
                  flex: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(
                      post['image'],
                      fit: BoxFit.cover,
                      height: 205,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    post['text'].length > 15
                        ? '${post['text'].substring(0, 14)}...'
                        : post['text'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('浏览量: ${post['views']}'),
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 14,color: Colors.red,),
                          const SizedBox(width: 4),
                          Text('${post['likes']}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
