import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/detail_page.dart';

class HomePage extends StatefulWidget {
  
 _HomePageState createState()=>_HomePageState();
}
class _HomePageState extends State<HomePage>{

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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/user_images/user-1.png'),
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
                    image: AssetImage('assets/user_images/user-1.png'), // 替换为你的图片路径
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
      body: 
      Stack(
      children: [  
      posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,  //一共两列
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0,
                childAspectRatio: 0.68//长宽比为0.75
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),//修剪图片为圆角半径10
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(post: posts[index]), // 传递post数据到详情页
                            ),
                          );
                        },
                      child:  Flexible(
                        flex: 8,
                        child:  ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.asset(
                          posts[index]['image'],
                          fit: BoxFit.cover,
                          height: 205,
                          width: double.infinity,
                        ),
                      )
                      )
                      ),
                      Flexible(
                        flex: 1,
                      child:  Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          posts[index]['text'].length>15 ?'${posts[index]['text'].substring(0,14)}...':posts[index]['text'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      )
                      ),
                      Flexible(
                        flex: 1,                    
                      child :Padding(
                        padding: const EdgeInsets.only(bottom: 2,top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('浏览量: ${posts[index]['views']}'),
                            Row(
                              children: [
                                const Icon(Icons.thumb_up, size: 14),
                                const SizedBox(width: 4),
                                Text('${posts[index]['likes']}'),
                              ],
                            ),
                          ],
                        ),
                      )
                      )             
                    ],
                  ),
                );
              },
            ),
            Positioned( //右下角放置用户发布动态按钮
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor:  Color.fromARGB(255, 142, 127, 192),
                onPressed: (){},
                child: Icon(Icons.add),                
              )

            )
      ]
      )
    );
  }
}