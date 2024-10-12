// 个人主页的偏好设置栏
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/Notification_dialog.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/about_us_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/account_security_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/language_dialog.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/theme_dialog.dart';
class PreferencesView extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final List<String> preferences_bar_Name = ['Account and security', 'News and Reminders', 'Theme','Language setting','About Us','Logout'];
  final List<bool> foodHighlights = [true, true, true]; // 示例

  PreferencesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            if(index==0){
              //选择Account and security
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context)=>AccountSecurityPage())
              );
            }
            else if(index==1){
              //选择News and Reminders
              NotificationDialog.show(context);
            }
            else if(index==2){
              //选择Theme
              ThemeDialog.show(context);
            }
            else if(index ==3){
              LanguageDialog.show(context);
              //选择Language setting
            }
            else if(index==4){
              //选择About Us
              Navigator.push(
                context, 
                MaterialPageRoute(builder:(context)=>AboutUsPage() )
              );
            }
            else{
              //选择Logout
            }
          },
         child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 阴影颜色
                  spreadRadius: 2, // 扩散半径
                  blurRadius: 5, // 模糊半径
                  offset: const Offset(0, 3), // 偏移量 (x, y)
                ),
              ],
               gradient: LinearGradient(
                begin: Alignment.bottomLeft, // 左下角
                end: Alignment.topRight,     // 右上角
                colors: [
                   const Color.fromARGB(255, 232, 204, 237).withOpacity(0.4), // 渐变的终止颜色
                  const Color.fromARGB(255, 216, 228, 238).withOpacity(0.4), // 渐变的起始颜色
                ],
              ),
            ),
            // 增加整体左右的内边距
            padding: const EdgeInsets.symmetric(horizontal: 5), // 设置容器的左右内边距
            child: Row(
              children: [
                // 卡片内容
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10, left: 20, right: 10), // 调整文字内边距
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              preferences_bar_Name[index],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 15,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
        separatorBuilder: (_, index) => const SizedBox(
          height: 15,
        ),
        itemCount: preferences_bar_Name.length,
      ),
    );
  }
}