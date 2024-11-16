import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ChatPage/chatList_page.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/first_post_repository.dart';
import 'package:gym_detector_ios/module/cache_module/first_post.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/Post/post_api.dart';
import 'package:gym_detector_ios/services/utils/handle.dart';
import 'package:gym_detector_ios/widgets/networkerror_screen.dart';
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
  late Future<HandleError> _futurePosts; // 异步获取帖子数据
   HandleError first_post=HandleError(code: 0, isError: true, data: {});
  List<Map<String, dynamic>> posts=[];
  @override
  void initState()  {
    super.initState();
    _futurePosts= _fetchAndCachePosts();
    _futurePosts.then((result){
      first_post=result;
      return result;
    });
    // 异步获取首次数据
  }

  Future<HandleError> _fetchAndCachePosts() async {
  try {
    final handle = await PostApi.fetchMorePosts({
      'user_id': GlobalUser().user!.user_id,
      'pageNumber': '1',
    });
    
    // Cache the fetched data locally
    await FirstPostRepository.addFirstPost(FirstPost(data: handle.data['data']));
    return handle;
  } catch (e) {
    // Handle the error by falling back on cached data if available
    final cachedData = await FirstPostRepository.getFirstPosts();
    
    if (cachedData == null) {
      return HandleError(code: 0, isError: true, data: {});
    } else {
      return HandleError(code: 200, isError: false, data: {'data':cachedData,'msg':'Successful!'});
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
  return FutureBuilder<HandleError>(
    future: _futurePosts, // 使用你的 Future
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator()); // 显示加载动画
      } else if (snapshot.hasError) {
        return NetworkErrorScreen();
      }  else {
        final List<Widget> _pages = [
          HomePage(initialPosts: first_post),
          AppPage(),
          ChatlistPage(),
          ProfilePage(selected: 0),
        ];
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color.fromARGB(255, 169, 124, 232),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      }
    },
  );
}

}