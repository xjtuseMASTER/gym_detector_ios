import 'dart:convert';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:netease_corekit_im/router/imkit_router.dart';
// import 'package:netease_corekit_im/router/imkit_router_constants.dart';
import 'package:gym_detector_ios/services/utils/custom_http_client.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/module/user_preferences.dart';
import 'package:gym_detector_ios/provider/theme_provider.dart';
import 'package:gym_detector_ios/userScreen/main_view.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:nim_chatkit_ui/chat_kit_client.dart';
import 'package:nim_contactkit_ui/contact_kit_client.dart';
import 'package:nim_conversationkit_ui/conversation_kit_client.dart';
import 'package:nim_searchkit_ui/search_kit_client.dart';
import 'package:nim_teamkit_ui/team_kit_client.dart';
import 'package:provider/provider.dart';
import 'appScreen/main_screen.dart'; // 替换为你的主页面文件路径
import 'package:shared_preferences/shared_preferences.dart';

// 初始化全局的 CustomHttpClient 实例
final CustomHttpClient customHttpClient = CustomHttpClient();
void main() {
  final cloudinary = CloudinaryPublic('dqfncgtzx', 'FiformAi', cache: false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // 提供ThemeProvider
        Provider<CloudinaryPublic>.value(
            value: cloudinary), // 注入 CloudinaryPublic 实例
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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

  Future<bool> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final int? loginTime = prefs.getInt('login_time');

    if (userId != null) {
      // 检查登录时间是否超过7天
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - loginTime! <= 7 * 24 * 60 * 60 * 1000) {
        // 登录未过期，恢复用户数据到全局变量类
        Person? user = await fetchUserFromBackend(context, userId);
        UserPreferences userPreferences =
            await fetchUserPreferencesFromBackend(userId);
        GlobalUser().setUser(user!);
        GlobalUserPreferences().setUserPreferences(userPreferences);
        return true; // 用户已登录且未过期
      }
    }
    return false; // 用户未登录或已过期
  }

  // 登录逻辑获取用户信息
  Future<Person?> fetchUserFromBackend(
      BuildContext context, String user_id) async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
          Uri.parse('${Http.httphead}/user/getuser').replace(
              queryParameters: {'user_id': user_id, 'own_id': user_id}));
      if (response.statusCode == 200) {
        // 请求成功
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody);
        final data = jsonResponse['data'];

        return Person(
            user_name: data['user_name'] ?? "",
            selfInfo: data['selfIntro'] ?? "",
            gender: data['gender'] ?? "",
            avatar: data['avatar'] ?? "",
            user_id: data['user_id'] ?? "",
            email: data['email'] ?? "",
            password: data['password'] ?? "",
            likes_num: data['likes_num'] ?? 0,
            birthday: data['birthday'] ?? "",
            collects_num: data['collects_num'] ?? 0,
            followers_num: data['followers_num'] ?? 0);
      } else {
        // 处理非 200 状态码
        LoadingDialog.hide(context);
        CustomSnackBar.showFailure(
            context, 'Server Error: ${response.statusCode}');
        return null; // 返回 null 表示获取失败
      }
    } catch (e) {
      // 捕获网络异常
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
      return null; // 返回 null 表示获取失败
    }
  }

//获取用户偏好设置
  Future<UserPreferences> fetchUserPreferencesFromBackend(
      String user_id) async {
    final response = await customHttpClient.get(
      Uri.parse('${Http.httphead}/user_preference/getpreferences').replace(
        queryParameters: {
          'user_id': user_id, // 传入 user_id 参数
        },
      ),
    );
    if (response.statusCode == 200) {
      //解析jsonshuju
      final jsonResponse = json.decode(response.body);
      //提取data
      final data = jsonResponse['data'];

      return UserPreferences.fromJson(data);
    } else {
      throw Exception('Failed to load userpreferrences');
    }
  }
}
