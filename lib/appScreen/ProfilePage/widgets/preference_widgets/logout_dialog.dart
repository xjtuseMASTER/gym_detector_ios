
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/first_post_repository.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/user_preferences_repository.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/user_repository.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/services/api/Auth/logout_api.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/userScreen/main_view.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';

class LogoutDialog {
  static show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 圆角设计
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF755DC1),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Whether to log out the user?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // 使按钮居中
          actions: <Widget>[
            ElevatedButton(
            onPressed: () async {
                // 清除后端用户会话数据
                final Handle=await LogoutApi.Userlogout({
                              'email':GlobalUser().user!.email, // 邮箱
                              'password': GlobalUser().user!.password//密码
                            });
                if(Handle.isError)
                {
                  HandleHttpError.handleErrorResponse(context, Handle.code);
                }
                else{
                // 清除用户数据缓存数据
                await clearUserData();
                // 关闭弹窗
                Navigator.of(context).pop();

                // 导航至登录页面并清空导航栈，防止左滑返回
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainView()),
                  (Route<dynamic> route) => false, // 清空导航栈
                );
                CustomSnackBar.showSuccess(context, "Logout successfully！");
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Comfirm',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Cancle',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
  static Future<void> clearUserData () async{
    GlobalUser().clearUser();
    GlobalUserPreferences().clearUserPreferences();
    await UserRepository.logout();
    await UserPreferencesRepository.clearUserPreferences();
    await FirstPostRepository.clear();

  }
}