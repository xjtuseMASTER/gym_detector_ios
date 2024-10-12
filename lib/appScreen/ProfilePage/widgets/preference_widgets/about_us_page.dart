//团队介绍页面
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
             color: Color(0xFF755DC1), // 设置颜色
            fontSize: 25, // 字体大小
            fontFamily: 'Poppins', // 设置字体
            fontWeight: FontWeight.w600, // 字体粗细
          ),
          ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Section
              const Text(
                'Our Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We come from Xi’an Jiaotong University, grade 22 software engineering major'
                'We are a passionate and creative team dedicated to providing users with the highest quality service and product experience.'
                'Our team members come from multiple technical fields and share a passion for technological innovation.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              // Software Section
              const Text(
                'Our Product',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'The software is designed to provide users with convenient motion tracking and motion detection functions，'
                'Help users optimize their fitness experience through visual technology.'
                'We uphold the concept of customer first,'
                'Continue to provide users with accurate and intelligent solutions.'
                'Let everyone enjoy the beauty of sports and fitness together',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              // Optional: Add Image (Team or Product)
              // Center(
              //   child: Image.network(
              //     'https://via.placeholder.com/300x200.png?text=Our+Team', // Replace with actual image URL
              //     height: 200,
              //     width: 300,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showcontactway(context);
                  },
                  child: Text('contact us'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //联系方式弹窗
  void showcontactway(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 圆角设计
          ),
          title: const Text('Contact Way', style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF755DC1))),
          content: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
             mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'email: 1192597201@qq.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                )),
              const SizedBox(height: 5),
              const Text(
                'phone(+86):18759601242 ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                )),
                const SizedBox(height: 5),
              const Text(
                'githup:1192597201@qq.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                )),
            ]
          )
          ),
            // 取消按扭
           actionsAlignment: MainAxisAlignment.center, // 使取消按钮居中
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.grey, // 阴影颜色
                elevation: 5, // 阴影高度
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // 圆角
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ]
        );
      },
    );
  }
}