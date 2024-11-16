import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/services/api/User/changeuser_api.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
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
  CloudinaryPublic? cloudinary;
  @override
  void initState() {
    super.initState();
    cloudinary = Provider.of<CloudinaryPublic>(context,
        listen: false); // 在 initState 中获取实例
  }

  // 选择照片并上传
  Future<void> _pickImage(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
        LoadingDialog.show(context, 'uploading...');
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      try {
        CloudinaryResponse response = await cloudinary!.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        await ChangeuserApi.uploadProfilePhoto(context, GlobalUser().user!.user_id, response.url);
        LoadingDialog.hide(context);
      } on CloudinaryException catch (e) {
        CustomSnackBar.showFailure(context, 'Network Error!');
      }
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
                            ? FileImage(_imageFile!)
                                as ImageProvider<Object> // 如果用户上传了图片，使用本地文件
                            : NetworkImage(
                                widget.person.avatar), // 如果没有本地文件，使用网络图片
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 右下角的小加号
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: () {
                        _pickImage(context);
                      }, // 点击加号时打开相册选择图片
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
