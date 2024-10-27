// 用户发布动态的页面
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
   final TextEditingController _headerController = TextEditingController();
    final TextEditingController _captionController = TextEditingController();
    final ImagePicker _picker = ImagePicker();
    List<XFile>? _images = [];
    List<String> uploadedImages = [];
    String post_id='';
    CloudinaryPublic ?cloudinary;
    Map<String,dynamic> NewPost={
        "postId": "",
        "autherId": GlobalUser().getUser()!.user_id,
        "title": "",
        "content": "",
        "likesNum": 0,
        "collectsNum": 0,
        "picList": []
      };
    
    @override
    void initState() {
      super.initState();
      cloudinary = Provider.of<CloudinaryPublic>(context, listen: false); // 在 initState 中获取实例
    }
    // 设置最大照片数量
    final int maxImages = 3;


Future<void> _pickImages() async {
        final List<XFile>? selectedImages = await _picker.pickMultiImage();

        if (selectedImages != null) {
          // 计算当前已选中的图片数量
          int currentCount = _images?.length ?? 0;

          // 检查选择的图片数量是否超过最大限制
          if (currentCount + selectedImages.length <= maxImages) {
            setState(() {
              _images = [...?_images, ...selectedImages]; // 合并新选中的图片和当前已选中的图片
            });
          } else {
            // 提示用户选择的图片数量超过限制
            final int remaining = maxImages - currentCount;
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Pictures Limit'),
                  content: Text('You can only select $maxImages pictures。Only $remaining more'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Comfirm'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
  Future<void> _takePhoto() async {

      // 访问用户相机进行拍摄
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // 计算当前已选中的图片数量
        int currentCount = _images?.length ?? 0;

        // 检查当前图片数量是否小于最大限制
        if (currentCount < maxImages) {
          setState(() {
            _images?.add(photo);
          });
        } else {
          // 提示用户达到最大照片限制
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Pictures Limit'),
                content: Text('You can only select $maxImages pictures'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('comfirm'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
//将照片一张一张上传到云床
Future<void> uploadImagesToCloudinary() async {
  try {
    for (var image in _images!) {
      // 异步上传每张图片
      CloudinaryResponse response = await cloudinary!.uploadFile(
        CloudinaryFile.fromFile(
          image.path, // 使用 XFile 的路径
          identifier: image.name, // 文件标识符
        ),
      );
      // 将每个上传结果添加到列表中
      uploadedImages.add(response.secureUrl);
    }
  } catch (e) {
     // 捕获网络异常，如网络连接超时或其他错误
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('NetWork Error'),
          content: Text('Can not fetch Data'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Comfirm'),
            ),
          ],
        );
      },
    );
  }
}
//发布帖子上传数据
Future<void> _handleRelease(BuildContext context) async {
  LoadingDialog.show(context, 'Releasing...'); // 显示加载指示器

  try {
    // 首先上传图片
    await uploadImagesToCloudinary();

    // 将照片和帖子内容上传到后端
    List<Map<String, String>> picLists = uploadedImages.map((url) {
      return {"picUrl": url};
    }).toList();

    Map<String, dynamic> postSummary = {
      'user_id': GlobalUser().getUser()!.user_id,
      'title': _headerController.text,
      'content': _captionController.text,
      'picList': picLists
    };

    NewPost['picList'] = picLists;
    NewPost['post_id'] = post_id;
    NewPost['title'] = _headerController.text;
    NewPost['content'] = _captionController.text;

    // 发送 POST 请求到后端
    final response = await http.post(
      Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/post/release'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(postSummary),
    );

    if (response.statusCode == 200) {
      // 处理返回的数据
      final jsonResponse = json.decode(response.body);
      post_id = jsonResponse['data']['post_id'];
      print('数据获取成功');
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Release Successfully！');
    } else {
      // 根据不同状态码显示错误信息
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

      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, errorMessage);
    }
  } catch (e) {
    // 捕获网络异常并显示错误提示
    LoadingDialog.hide(context);
    CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
  }
}
//判断帖子是否合法
bool _isFormValid() {
  return _headerController.text.isNotEmpty &&  // 标题不为空
         _captionController.text.isNotEmpty && // 配文不为空
         _images != null && _images!.isNotEmpty; // 图片列表不为null且不为空 
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Release dynamic', 
        style: TextStyle(
           color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
        actions: [
          TextButton(
            onPressed: () async{
             if (_isFormValid()) {
                // 如果标题、配文和图片都不为空，执行发布操作
                await _handleRelease(context);
                //返回主页面
                Navigator.pop(context,NewPost);
              } else {
                // 如果任意一项为空，显示提示
                CustomSnackBar.showFailure(context, "Please complete the content and select at least one picture");
              }
            },
            child: Text('release', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _pickImages(), // 选择多张图片
              child: DottedBorder(
                color: Colors.grey,
                strokeWidth: 2,
                dashPattern: [6, 4],
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: _images == null || _images!.isEmpty
                        ? Icon(Icons.add, size: 50, color: Colors.grey)
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _images!.map((image) {
                              return Image.file(
                                File(image.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            //标题栏
                TextField(
                  controller: _headerController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    hintText: 'Enter header...',
                    border: OutlineInputBorder(),
                  ),
                ),
          const SizedBox(height: 25),
          // 配文栏
                TextField(
                  controller: _captionController,
                  maxLines: 5,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: 'Enter caption...',
                    border: OutlineInputBorder(),
                  )
                ),
          ],
        ),
      ),
    );
  }
}