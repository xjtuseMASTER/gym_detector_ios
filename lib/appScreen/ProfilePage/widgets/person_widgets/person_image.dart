import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class PersonImage extends StatefulWidget {
  final Person person;
  PersonImage({required this.person});

  @override
  _PersonImageState createState() => _PersonImageState();
}

class _PersonImageState extends State<PersonImage> {
  File? _imageFile;
  CloudinaryPublic ?cloudinary;
  @override
  void initState() {
    super.initState();
    cloudinary = Provider.of<CloudinaryPublic>(context, listen: false); // 在 initState 中获取实例
  }
  // 选择照片并上传
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    try {
        CloudinaryResponse response = await cloudinary!.uploadFile(
            CloudinaryFile.fromFile(pickedFile.path, resourceType: CloudinaryResourceType.Image),
        );
          print(response.secureUrl);
          GlobalUser().user!.setAvatar(response.secureUrl);
          print(GlobalUser().user!.avatar);
          await _uploadProfilePhoto(GlobalUser().user!.user_id,response.url);
      } on CloudinaryException catch (e) {
       CustomSnackBar.showFailure(context, 'Network Error!');
      }
    }
  }
  // 将secureurl返回给后端
  Future<void> _uploadProfilePhoto(String user_id,String secureurl) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'uploading...');

    // 发送请求
    final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/user/changeprofile_photo').replace(
          queryParameters: {
            'user_id': user_id, // 传入 user_id 参数
            'sucure_url':secureurl 
          },
        ),
      );

    if (response.statusCode == 200) {
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Upload Successfully');
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
      LoadingDialog.hide(context);
       CustomSnackBar.showFailure(context,errorMessage);
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    LoadingDialog.hide(context);
     CustomSnackBar.showFailure(context,'Network Error: Cannot upload data');
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.all(15),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(-1, 10),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 头像图片
                 Container(
                    width: 220,
                    height: 220,
                   decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider<Object> // 如果用户上传了图片，使用本地文件
                            : NetworkImage(widget.person.avatar), // 如果没有本地文件，使用网络图片
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 右下角的小加号
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: _pickImage,  // 点击加号时打开相册选择图片
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}