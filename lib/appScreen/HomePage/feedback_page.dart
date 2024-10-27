import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/logout_dialog.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
// 从主页进入的用户反馈界面
class FeedbackPage extends StatefulWidget {
  _FeedbackPageState createState()=> _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>{
 Future<void> _handleFeedbackSubmission(BuildContext context,String userId,String content) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Submitting...');

    // 发送请求
    final response = await customHttpClient.get(Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/user/feedback').replace(
      queryParameters: {
            'user_id': userId, 
            'content':content
          },
    ));
    if (response.statusCode == 200) {
      // 请求成功
      print('数据获取成功');
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Submitted Successfully, Thank you!');
    } else {
      // 请求失败，根据状态码显示不同的错误提示
      String errorMessage='';
      if (response.statusCode == 404) {
        errorMessage = 'Resource not found';
      } else if (response.statusCode == 500) {
        errorMessage = 'Server error';
      } else if (response.statusCode == 403) {
        errorMessage = 'Permission denied';
      } else {
        errorMessage = 'Unknown error';
      }

      // 隐藏加载对话框，显示错误提示框
      // ignore: use_build_context_synchronously
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context,errorMessage);
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    // ignore: use_build_context_synchronously
    LoadingDialog.hide(context);
    CustomSnackBar.showFailure(context,'Network Error: Cannot fetch data');
  }
}

  @override
  Widget build(BuildContext context) {
    final TextEditingController _feedbacktextcontroller=TextEditingController();
    return Scaffold(
      appBar: AppBar(
       leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text('Submit Feedback', 
        style: TextStyle(
           color: Color(0xFF755DC1),
                    fontSize: 25.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0.w),
        child: Column(
          children: [
            // 卡片部分
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r), // 确保图片的圆角与卡片一致
                child: Container(
                  height: 290.h, // 卡片高度
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/bar_images/bar3.jpg'), // 背景图片
                      fit: BoxFit.contain,  // 确保图片填充整个卡片
                    ),
                  ),
                ),
              ),
            ),
             SizedBox(height: 20.h),

            // 大字标题
             Text(
              "Let's hear you!",
              style: TextStyle(
               color: Color(0xFF755DC1),
                    fontSize: 28.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 30.h),

            // 输入框部分
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5.r,
                    blurRadius: 10.r,
                    offset: Offset(0, 3), // 阴影的偏移量
                  ),
                ],
              ),
              child: TextField(
                controller:_feedbacktextcontroller,
                maxLines: (8 * ScreenUtil().scaleHeight).toInt(),
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  filled: true,
                  fillColor: Colors.white, // 输入框背景色
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // 提交按钮
            ElevatedButton(
              onPressed: () async{
                if(_feedbacktextcontroller.text.isEmpty)//判断输入框为不为空
                {
                  CustomSnackBar.showFailure(context, 'Please input your idea before submitting!');
                }
                else{
                await _handleFeedbackSubmission(context, GlobalUser().getUser()!.user_id,_feedbacktextcontroller.text);
                _feedbacktextcontroller.text='';//重置
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h), backgroundColor: const Color.fromARGB(255, 188, 134, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ), // 按钮颜色
              ),
              child:  Text(
                'Submit',
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}