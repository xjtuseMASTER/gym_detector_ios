import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/first_post_repository.dart';
import 'package:gym_detector_ios/module/cache_module/first_post.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/Post/post_api.dart';
import 'package:nim_chatkit_ui/chat_kit_client.dart';
import 'package:nim_contactkit/repo/contact_repo.dart';
import 'package:nim_conversationkit/repo/conversation_repo.dart';
import 'package:netease_corekit_im/router/imkit_router_factory.dart';
import 'package:nim_conversationkit_ui/page/conversation_page.dart';
import 'HomePage/home_page.dart';
import 'AppPage/app_page.dart';
import 'ProfilePage/profile_page.dart';

const channelName = "com.netease.yunxin.app.flutter.im/channel";
const pushMethodName = "pushMessage";

class MainScreen extends StatefulWidget {
  MainScreen(); // 构造函数

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int chatUnreadCount = 0;
  int contactUnreadCount = 0;
  late Future<List<Map<String, dynamic>>> _futurePosts; // 异步获取帖子数据

  initUnread() {
    ConversationRepo.getMsgUnreadCount().then((value) {
      if (value.isSuccess && value.data != null) {
        setState(() {
          chatUnreadCount = value.data!;
        });
      }
    });
    ContactRepo.getNotificationUnreadCount().then((value) {
      if (value.isSuccess && value.data != null) {
        setState(() {
          contactUnreadCount = value.data!;
        });
      }
    });
    ContactRepo.registerNotificationUnreadCountObserver().listen((event) {
      setState(() {
        contactUnreadCount = event;
      });
    });
  }

  //分发消息，跳转到聊天页面
  void _dispatchMessage(Map? params) {
    var sessionType = params?['sessionType'] as String?;
    var sessionId = params?['sessionId'] as String?;
    if (sessionType?.isNotEmpty == true && sessionId?.isNotEmpty == true) {
      if (sessionType == 'p2p') {
        goToP2pChat(context, sessionId!);
      } else if (sessionType == 'team') {
        goToTeamChat(context, sessionId!);
      }
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == pushMethodName && call.arguments is Map) {
      _dispatchMessage(call.arguments);
    }
  }

  ///解析从Native端传递过来的消息，并分发
  void _handleMessageFromNative() {
    const channel = MethodChannel(channelName);

    //注册回调，用于页面没有被销毁的时候的回调监听
    channel.setMethodCallHandler((call) => _handleMethodCall(call));

    //方法调用，用于页面被销毁时候的情况
    channel.invokeMapMethod<String, dynamic>(pushMethodName).then((value) {
      // Alog.d(tag: 'HomePage', content: "Message from Native is = $value}");
      _dispatchMessage(value);
    });
  }

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
  void dispose() {
    super.dispose();
    ChatKitClient.instance.unregisterRevokedMessage();
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
              ConversationPage(
                onUnreadCountChanged: (unreadCount) {
                  setState(() {
                    chatUnreadCount = unreadCount;
                  });
                },
              ),
              ProfilePage(selected: 0),
            ];
            return _pages[_selectedIndex];
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:
            const Color.fromARGB(255, 169, 124, 232), // 设置选中的图标颜色
        unselectedItemColor: Colors.grey, // 设置未选中的图标颜色
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
