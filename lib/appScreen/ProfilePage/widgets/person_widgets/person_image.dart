import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PersonImage extends StatefulWidget {
  final Person person;
  PersonImage({required this.person});

  @override
  _PersonImageState createState() => _PersonImageState();
}

class _PersonImageState extends State<PersonImage> {
  File? _imageFile;

  // 选择照片的函数
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // 调用后端接口上传图片
      _uploadProfilePhoto(_imageFile!);
    }
  }

  // 上传头像到后端的函数
  Future<void> _uploadProfilePhoto(File imageFile) async {
    // 这里是上传文件到后端的逻辑
    // 可以通过 HTTP 请求把图片文件上传到服务器
    // 例如使用 dio 或 http 库实现上传
    print("Uploading photo to backend...");
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
                            : NetworkImage(widget.person.profile_photo), // 如果没有本地文件，使用网络图片
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