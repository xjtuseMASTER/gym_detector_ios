import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/AppPage/VideoAnalysis_page.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:gym_detector_ios/widgets/persentageload_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class UploadPage extends StatefulWidget {
  final int index;
  UploadPage({required this.index});
  _UploadPage createState() => _UploadPage();
}

class _UploadPage extends State<UploadPage> {
  CloudinaryPublic? cloudinary; // 云端上传器
  final List<String> names = [
    'Pull-ups',
    'Push up',
    'Squat',
    'Deadlift',
    'Plank',
    'bench press',
    'Sit up',
    'Dumbbell fly'
  ];
  final _picker = ImagePicker();
  File? _video;
  bool isSelectedVideo = false; // 是否选择了正确的视频
  String? videoThumbnailPath;
 String pic_url = '';

  @override
  void initState() {
    super.initState();
    cloudinary = Provider.of<CloudinaryPublic>(context,
        listen: false); // 在 initState 中获取实例
  }

  // // 从相册选择视频上传
  // Future<void> _pickVideo() async {
  //   final XFile? selectedVideo =
  //       await _picker.pickVideo(source: ImageSource.gallery);

  //   if (selectedVideo != null) {
  //     VideoPlayerController videoController =
  //         VideoPlayerController.file(File(selectedVideo.path));
  //     await videoController.initialize();
  //     final videoDuration = videoController.value.duration;

  //     if (videoDuration.inSeconds > 60) {
  //       CustomSnackBar.showFailure(
  //           context, 'Please select a video under one minute！');
  //       return;
  //     }

  //     setState(() {
  //       isSelectedVideo = true;
  //       _video = File(selectedVideo.path);
  //     });

  //     final String? videoThumbnail = await VideoThumbnail.thumbnailFile(
  //       video: _video!.path,
  //       imageFormat: ImageFormat.JPEG,
  //       maxWidth: 256,
  //       quality: 50,
  //     );

  //     setState(() {
  //       videoThumbnailPath = videoThumbnail;
  //     });
  //   }
  // }
   // 显示选择对话框
  Future<void> _showPickOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 从相册或相机选择视频
  Future<void> _pickVideo(ImageSource source) async {
    final XFile? selectedVideo = await _picker.pickVideo(source: source);

    if (selectedVideo != null) {
      await _handleSelectedVideo(selectedVideo);
    }
  }


  
// 处理选择的视频
Future<void> _handleSelectedVideo(XFile video) async {
  // 如果是相机拍摄的视频，进行压缩
  if (video.path.contains('Camera')) {
    // 开始压缩，调整分辨率和帧率
    final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.LowQuality, // 设置低质量
      deleteOrigin: false, // 保留原视频
    );

    if (compressedVideo != null) {
      setState(() {
        _video = File(compressedVideo.path!);
        isSelectedVideo = true;
      });
    }
  } else {
    setState(() {
      _video = File(video.path);
      isSelectedVideo = true;
    });
  }

  // 视频缩略图生成
  final String? videoThumbnail = await VideoThumbnail.thumbnailFile(
    video: _video!.path,
    imageFormat: ImageFormat.JPEG,
    maxWidth: 256,
    quality: 50,
  );

  setState(() {
    videoThumbnailPath = videoThumbnail;
  });

  // 检查视频时长
  VideoPlayerController videoController =
      VideoPlayerController.file(File(_video!.path));
  await videoController.initialize();
  final videoDuration = videoController.value.duration;

  if (videoDuration.inSeconds > 60) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a video under one minute!')),
    );
    return;
  }
}

  Future<void> _handleSubmit(BuildContext context, String userId) async {
    if (_video == null) return;

    try {
      final videoFile = File(_video!.path);
      final videoSize = await videoFile.length();
      final maxSize = 100 * 1024 * 1024; // 100MB 限制

      if (videoSize > maxSize) {
        CustomSnackBar.showFailure(context, 'Video size exceeds 100MB limit');
        return;
      }

      LoadingDialog.show(context, "Uploading video...");

      try {
        final res = await cloudinary!.uploadFileInChunks(
          CloudinaryFile.fromFile(
            _video!.path,
            folder: 'hello-folder',
            context: {
              'alt': 'Hello',
              'caption': 'An example upload in chunks',
            },
          ),
          chunkSize: 10000000, // 分块大小5MB
        );
          // 使用 replaceFirst
         pic_url = res!.secureUrl.replaceFirst(RegExp(r'\.mov$'), '.jpg');
        // 删除视频和缩略图文件以释放资源
        _cleanupFiles();
        LoadingDialog.hide(context);
        if (res?.secureUrl == null) {
          throw Exception('Upload failed: No secure URL received');
        }
        LoadingDialog.show(context, 'Analyzing video...');
        // 不要隐藏 LoadingDialog 太早
        if (context.mounted) {
          final response = await customHttpClient
              .get(
                Uri.parse('${Http.httphead}/history/upload')
                    .replace(queryParameters: {
                  'user_id': userId,
                  'video_url': res?.secureUrl,
                  'app_id': widget.index.toString(),
                }),
              )
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            LoadingDialog.hide(context);
            final decodedBody = utf8.decode(response.bodyBytes); 
            final jsonResponse = json.decode(decodedBody);
            final List<Map<String, dynamic>> analysisList =
                List<Map<String, dynamic>>.from(
                    jsonResponse['data']);
            // 直接在当前页面显示 VideoInfoDialog
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VideoAnalysisPage(analysisList: analysisList,pic_url: pic_url,)));
          } else {
            _handleErrorResponse(context, response.statusCode);
          }
        }
      } catch (uploadError) {
        if (context.mounted) {
          CustomSnackBar.showFailure(
              context, 'Upload failed: ${uploadError.toString()}');
        }
        rethrow;
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showFailure(context, 'Network Error: ${e.toString()}');
      }
    }
  }

  // 删除视频文件和缩略图以释放存储空间
  void _cleanupFiles() {
    if (_video != null) {
      _video!.deleteSync();
      _video = null;
    }
    if (videoThumbnailPath != null) {
      File(videoThumbnailPath!).deleteSync();
      videoThumbnailPath = null;
    }
    setState(() {
      isSelectedVideo = false;
    });
  }

  // 错误处理辅助函数
  void _handleErrorResponse(BuildContext context, int statusCode) {
    String errorMessage;
    switch (statusCode) {
      case 404:
        errorMessage = 'Resource not found';
        break;
      case 500:
        errorMessage = 'Server error';
        break;
      case 403:
        errorMessage = 'Permission denied';
        break;
      default:
        errorMessage = 'Unknown error';
    }
    CustomSnackBar.showFailure(context, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 212, 141, 240)),
        ),
        title: Text(
          'Upload Video',
          style: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
              child: Container(
                height: 250.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/gymplan_images/sample${widget.index + 1}.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              names[widget.index],
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 30.h),
            GestureDetector(
              onTap: () => _showPickOptions(),
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
                    child: videoThumbnailPath == null
                        ? Column(
                            children: [
                              Icon(Icons.add, size: 60.sp, color: Colors.grey),
                              SizedBox(height: 5.h),
                              Text(
                                'Please select the video you wanna analyse.',
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.grey),
                              ),
                            ],
                          )
                        : Image.file(
                            File(videoThumbnailPath!),
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
            SizedBox(height: 25.h),
            ElevatedButton(
              onPressed: () async {
                if (!isSelectedVideo) {
                  CustomSnackBar.showFailure(
                      context, 'Please Select Video First！');
                } else {
                  await _handleSubmit(context, GlobalUser().getUser()!.user_id);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                backgroundColor: const Color.fromARGB(255, 188, 134, 232),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r)),
              ),
              child: Text(
                'Upload',
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
