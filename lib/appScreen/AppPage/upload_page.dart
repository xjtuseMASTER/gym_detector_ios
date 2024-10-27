import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:gym_detector_ios/widgets/persentageload_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
class UploadPage extends StatefulWidget {
  final int index;
  UploadPage({required this.index});
  _UploadPage createState()=>_UploadPage();

}
class _UploadPage extends State<UploadPage>{
  CloudinaryPublic ?cloudinary;//云端上传器
  final List<String> names=['Pull-ups','Push up','Squat',' Deadlift','Plank','bench press','Sit up','Dumbbell fly'];
                            //[‘引体向上’，‘俯卧撑’，‘深蹲’，‘硬拉’，‘平板支撑’，‘卧推’，‘仰卧起坐’，‘哑铃飞鸟’]
  final  _picker= ImagePicker();
  File? _Video;
  bool isSelectedvedio=false;//是否选择正确视频
  String? video_thumbnail_path;
  double _uploadingPercentage=0.0;
  //初始化
  void initState() {
      super.initState();
      cloudinary = Provider.of<CloudinaryPublic>(context, listen: false); // 在 initState 中获取实例
    }
  //从相册选择视频上传
  Future<void> _pickVideo() async {
  final XFile? selectedvideo = await _picker.pickVideo(source: ImageSource.gallery);
  
  if (selectedvideo != null) {
    // 初始化视频播放器控制器以获取视频时长
    VideoPlayerController videoController = VideoPlayerController.file(File(selectedvideo.path));
    await videoController.initialize();
    
    // 获取视频时长并检查是否超过1分钟（60秒）
    final videoDuration = videoController.value.duration;
    if (videoDuration.inSeconds > 60) {
      // 如果视频时长超过60秒，提示用户并返回
      CustomSnackBar.showFailure(context, 'Please select a video under one minute！');
      return;
    }

    // 视频时长符合要求，继续处理
    setState(() {
      isSelectedvedio=true;
      _Video = File(selectedvideo.path);
    });

    // 生成视频缩略图
    final String? video_thumbnail = await VideoThumbnail.thumbnailFile(
      video: _Video!.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 256, // 指定缩略图宽度
      quality: 50,
    );

    setState(() {
      video_thumbnail_path = video_thumbnail;
    });
  }
}
//提交上传视频
Future<void> _handleSummit(BuildContext context,String user_id)async{
try{
  final res = await cloudinary!.uploadFileInChunks(
  CloudinaryFile.fromFile(
    _Video!.path,
    folder: 'hello-folder',
    context: {
      'alt': 'Hello',
      'caption': 'An example upload in chunks',
    },
  ),
  chunkSize: 10000000,
  onProgress: (count, total) {
    setState(() {
      _uploadingPercentage = (count / total) * 100;
    });
    PersentageloadDialog.showUploadDialog(context, _uploadingPercentage);
    },
  );
  PersentageloadDialog.hide(context);//关闭上传进度条
   // 发送请求
    final response = await customHttpClient.get(
        Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/main/upload').replace(
          queryParameters: {
            'user_id': user_id, // 传入 user_id 参数
            'videourl':res!.secureUrl//视频云端url
          },
        ),
      );

    if (response.statusCode == 200) {
      // 请求成功
      print('数据获取成功');
      PersentageloadDialog.hide(context);//关闭上传进度条
    } else {
      // 请求失败，根据状态码显示不同的错误提示
      String errorMessage;
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
      PersentageloadDialog.hide(context);//关闭上传进度条
      CustomSnackBar.showFailure(context,errorMessage);
    }

}catch(e)
{
   // 捕获网络异常，如超时或其他错误
    LoadingDialog.hide(context);
    CustomSnackBar.showFailure(context,'Network Error: Cannot fetch data');
  }
}

  // //使用相机直接拍摄上传
  // Future<void> _takeVideo() async{
  //   final XFile? tokenvideo= await _picker.pickVideo(source: ImageSource.camera);
  //   if(tokenvideo!=null)
  //   {
  //     setState(() {
  //       _Video=tokenvideo;
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: const Icon(Icons.arrow_back,color: Color.fromARGB(255, 212, 141, 240)
          )),
        title:  Text(
          'Upload Video',
          style:TextStyle(
             color: Color(0xFF755DC1),
                    fontSize: 25.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r)
              ),
              child: Container(
                height: 250.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  image:DecorationImage(
                  image: AssetImage('assets/gymplan_images/sample${widget.index+1}.jpg'),
                  fit: BoxFit.cover
                  )
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 大字标题
             Text(
              names[widget.index],
              style:  TextStyle(
                fontSize: 25.sp, // 大字尺寸
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 30.h),
            GestureDetector(
              onTap: () => _pickVideo(), // 选择视频上传
              child: DottedBorder(
                color: Colors.grey,
                strokeWidth: 2,
                dashPattern: [6, 4],
                child: Container(
                  padding: EdgeInsets.only(top: 45.h),
                  height: 200.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                            child: video_thumbnail_path == null
                  ?  Column(
                    children: [
                        Icon(Icons.add, size: 60.sp, color: Colors.grey),
                        SizedBox(height: 5.h),
                        Text(
                          'Please select the video you wanna analyse.',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey
                          ),
                        )
                    ],
                    )
                  : Image.file(
                      File(video_thumbnail_path!),
                      width: 256.w,
                      height: 200.h,
                      fit: BoxFit.cover,
                    ),
                    
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
                        'Please select a video under one minute！',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              // 提交按钮
             SizedBox(height: 25.h),
            ElevatedButton(
              onPressed: () async{
                // 上传视频逻辑
                if(isSelectedvedio){
                  CustomSnackBar.showFailure(context, 'Please Select Video First！');

                }
                else{
                  await _handleSummit(context,GlobalUser().getUser()!.user_id);
                  CustomSnackBar.showSuccess(context, 'Uploaded Successfully');
                }

              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h), backgroundColor: const Color.fromARGB(255, 188, 134, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ), // 按钮颜色
              ),
              child: Text(
                'Upload',
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      )
    );
  }
}