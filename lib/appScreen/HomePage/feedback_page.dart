import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/Feedback/feedback_api.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
// 从主页进入的用户反馈界面
class FeedbackPage extends StatefulWidget {
  _FeedbackPageState createState()=> _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>{
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
                final queryParameters= {
                  'user_id': GlobalUser().getUser()!.user_id, 
                  'content':_feedbacktextcontroller.text
                };
                await FeedbackApi.handleFeedbackSubmission(context, queryParameters);
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