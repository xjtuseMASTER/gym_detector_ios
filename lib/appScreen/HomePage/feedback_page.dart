import 'package:flutter/material.dart';
// 从主页进入的用户反馈界面
class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _feedbacktextcontroller=TextEditingController();
    return Scaffold(
      appBar: AppBar(
       leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Submit Feedback', 
        style: TextStyle(
           color: Color(0xFF755DC1),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 卡片部分
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 290, // 卡片高度
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: AssetImage('assets/bar_images/bar3.jpg'), // 背景图片
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 大字标题
            const Text(
              "Let's hear you!",
              style: TextStyle(
               color: Color(0xFF755DC1),
                    fontSize: 28,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 30),

            // 输入框部分
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3), // 阴影的偏移量
                  ),
                ],
              ),
              child: TextField(
                controller:_feedbacktextcontroller,
                maxLines: 8, // 输入框高度
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.white, // 输入框背景色
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 提交按钮
            ElevatedButton(
              onPressed: () {
                // 提交反馈逻辑
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), backgroundColor: const Color.fromARGB(255, 188, 134, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ), // 按钮颜色
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}