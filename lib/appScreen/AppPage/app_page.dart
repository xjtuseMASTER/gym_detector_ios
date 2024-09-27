import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/AppPage/upload_page.dart';

class AppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose your plan',
          style: TextStyle(
            color: Color(0xFF755DC1), // 设置颜色
            fontSize: 25, // 字体大小
            fontFamily: 'Poppins', // 设置字体
            fontWeight: FontWeight.w600, // 字体粗细
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // 去除阴影
        centerTitle: true, // 标题居中
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 向左对齐
          children: [
            // 搜索框
            Container(
              margin: const EdgeInsets.only(bottom: 16), // 与图片留白
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  icon: Icon(Icons.search, color: Color(0xFF755DC1)),
                ),
              ),
            ),
            // 可滚动的图片列表
            Expanded(
              child: ListView(
                children: [
                  // 9 个图片
                  for (int index = 0; index < 9; index++)
                    GestureDetector(
                      onTap: () {
                        // 点击图片时跳转到详情页面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadPage(index: index),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/gymplan_images/sample${index + 1}.jpg', // 图片路径
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                  // 在最后一个图片下方显示“已经到达底部了”的文字
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'already on the bottom',
                        style: TextStyle(
                          color: Color(0xFF837E93),
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

