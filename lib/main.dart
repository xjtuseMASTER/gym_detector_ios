
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/first_post_repository.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/user_preferences_repository.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/user_repository.dart';
// import 'package:netease_corekit_im/router/imkit_router.dart';
// import 'package:netease_corekit_im/router/imkit_router_constants.dart';
import 'package:gym_detector_ios/services/utils/custom_http_client.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/provider/theme_provider.dart';
import 'package:gym_detector_ios/userScreen/main_view.dart';
import 'package:nim_chatkit_ui/chat_kit_client.dart';
import 'package:nim_contactkit_ui/contact_kit_client.dart';
import 'package:nim_conversationkit_ui/conversation_kit_client.dart';
import 'package:nim_searchkit_ui/search_kit_client.dart';
import 'package:nim_teamkit_ui/team_kit_client.dart';
import 'package:provider/provider.dart';
import 'appScreen/main_screen.dart'; // 替换为你的主页面文件路径

// 初始化全局的 CustomHttpClient 实例
final CustomHttpClient customHttpClient = CustomHttpClient();
void main() async{
  final PageController _pageController = PageController();
  final cloudinary = CloudinaryPublic('dqfncgtzx', 'FiformAi', cache: false);
  await UserRepository.init();  // 添加这行
  await UserPreferencesRepository.init(); // 添加这行
  await FirstPostRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // 提供ThemeProvider
        Provider<CloudinaryPublic>.value(
            value: cloudinary), // 注入 CloudinaryPublic 实例
      ],
      child: MyApp(controller: _pageController),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.controller}) : super(key: key);
  final PageController controller;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ///init all plugin here
  void _initPlugins() {
    ChatKitClient.init();
    TeamKitClient.init();
    ConversationKitClient.init();
    ContactKitClient.init();
    SearchKitClient.init();

    // IMKitRouter.instance.registerRouter(
    //     RouterConstants.PATH_MINE_INFO_PAGE, (context) => UserInfoPage());
  }

  @override
  void initState() {
    super.initState();
    _initPlugins();
    GestureBinding.instance.resamplingEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Provider 来获取 ThemeProvider 实例
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ScreenUtilInit(
      designSize: const Size(402, 920),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.currentTheme, // 根据用户偏好渲染主
          home: FutureBuilder(
            future: checkLoginStatus(context), // 检查登录状态
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 显示加载指示器
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // 处理错误
                return const MainView();
              } else {
                final bool isLoggedIn = snapshot.data as bool;
                if (isLoggedIn) {
                  
                  return MainScreen(); // 登录状态有效，导航到主页面
                } else {
                  return const MainView(); // 登录状态无效，导航到登录页面
                }
              }
            },
          ),
          routes: {
            '/main': (context) => MainScreen(), // 登录成功后进入主页面
          },
        );
      },
    );
  }
  //  判断用户是否已经登陆
  Future<bool> checkLoginStatus(BuildContext context) async {
     if(await UserRepository.isUserLoggedIn()){
      await fetchUserFromCache();
      return true;
     }
     else{
      return false;
     }
  }

 // 登录逻辑获取用户信息
  Future<void> fetchUserFromCache() async {
    final User=await UserRepository.getCurrentUser();
    GlobalUser().setUser(User!);
    final userperences=await UserPreferencesRepository.getUserPreferences();
    GlobalUserPreferences().setUserPreferences(userperences!);
  }

}
