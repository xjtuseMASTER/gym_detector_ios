// 用户发布动态的页面
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

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

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages;
      });
    }
  }//访问用户相册选择图片

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _images?.add(photo);
      });
    }
  }// 访问用户相机进行拍摄

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
            onPressed: () {
              // 发布动态逻辑
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