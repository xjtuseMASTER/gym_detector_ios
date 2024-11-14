import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ChatPage/chatList_page.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/first_post_repository.dart';
import 'package:gym_detector_ios/module/cache_module/first_post.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/Post/post_api.dart';
import 'HomePage/home_page.dart';
import 'AppPage/app_page.dart';
import 'ProfilePage/profile_page.dart';
class MainScreen extends StatefulWidget {
  MainScreen(); // 构造函数

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> _futurePosts; // 异步获取帖子数据

  @override
  void initState()  {
    super.initState();
    _futurePosts= _fetchAndCachePosts();
    // 异步获取首次数据
  }

  Future<List<Map<String, dynamic>>> _fetchAndCachePosts() async {
    try {
      final posts = await PostApi.fetchMorePosts({
        'user_id': GlobalUser().user!.user_id,
        'pageNumber': '1',
      });
      // 进行本地缓存
      await FirstPostRepository.addFirstPost(FirstPost(data: posts));
      return posts;
    } catch (e) {
      // Handle the error, fallback on cached data if available
      final cachedData = await FirstPostRepository.getFirstPosts();
      if (cachedData == null ) {
        return [];
      } else {
        return cachedData.data;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load posts'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts available'));
          } else {
            // 成功获取到数据后，展示页面
            final List<Map<String, dynamic>> posts = snapshot.data!;
            final List<Widget> _pages = [
              HomePage(initialPosts: posts),
              AppPage(),
              ChatlistPage(),
              ProfilePage(selected: 0),
            ];
            return _pages[_selectedIndex];
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 169, 124, 232), // 设置选中的图标颜色
        unselectedItemColor: Colors.grey, // 设置未选中的图标颜色
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}