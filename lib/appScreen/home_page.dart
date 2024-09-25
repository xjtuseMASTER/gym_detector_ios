import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  
 _HomePageState createState()=>_HomePageState();
}
class _HomePageState extends State<HomePage>{

  // 模拟动态数据
  final List<Map<String, dynamic>> posts = [
    {
      'image': 'assets/images/sample1.jpg',
      'text': '今日的深蹲训练完成了！',
      'views': 123,
      'likes': 45
    },
    {
      'image': 'assets/images/sample2.jpg',
      'text': '今天练习了引体向上',
      'views': 220,
      'likes': 89
    },
    {
      'image': 'assets/images/sample3.jpg',
      'text': '完美的俯卧撑！',
      'views': 310,
      'likes': 105
    },
    // 其他动态数据...
  ];
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/user_images/vector-4.png'),
              ),
              onPressed: () {
                // 点击头像，打开侧边栏
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Join us!',
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
              // 点击客服按钮的逻辑
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
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/user_images/vector-4.png'), // 替换为你的图片路径
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
              onTap: (){},
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
              onTap: () {},
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
              onTap: () {},
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
    );
  }
}