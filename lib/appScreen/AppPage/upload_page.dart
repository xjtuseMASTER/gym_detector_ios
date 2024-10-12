import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadPage extends StatefulWidget {
  final int index;
  UploadPage({required this.index});
  _UploadPage createState()=>_UploadPage();
}
class _UploadPage extends State<UploadPage>{
  final List<String> names=['Pull-ups','Push up','Squat',' Deadlift','Plank','bench press','Sit up','Dumbbell fly'];
                            //[‘引体向上’，‘俯卧撑’，‘深蹲’，‘硬拉’，‘平板支撑’，‘卧推’，‘仰卧起坐’，‘哑铃飞鸟’]
  final  _picker= ImagePicker();
  File? _Video;
  String? video_thumbnail_path;
  //从相册选择视频上传
  Future<void> _pickVideo() async{
    final XFile? selectedvideo = await _picker.pickVideo(source: ImageSource.gallery);
    if(selectedvideo!=null)
    {
      setState(() {
        _Video=File(selectedvideo.path);
      });
      //生成视频缩略图
      final String? video_thumbnail=await VideoThumbnail.thumbnailFile(
        video: _Video!.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128, // 指定缩略图宽度
        quality: 25,
      );
      setState(() {
        video_thumbnail_path=video_thumbnail;
      });
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
        title: const Text(
          'Upload Video',
          style:TextStyle(
             color: Color(0xFF755DC1),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image:DecorationImage(
                  image: AssetImage('assets/gymplan_images/sample${widget.index+1}.jpg'),
                  fit: BoxFit.cover
                  )
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 大字标题
             Text(
              names[widget.index],
              style: const TextStyle(
                fontSize: 25, // 大字尺寸
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () => _pickVideo(), // 选择视频上传
              child: DottedBorder(
                color: Colors.grey,
                strokeWidth: 2,
                dashPattern: [6, 4],
                child: Container(
                  padding: EdgeInsets.only(top: 45),
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                            child: video_thumbnail_path == null
                  ? const Column(
                    children: [
                        Icon(Icons.add, size: 60, color: Colors.grey),
                        SizedBox(height: 5),
                        Text(
                          'Please select the video you wanna analyse.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey
                          ),
                        )
                    ],
                    )
                  : Image.file(
                      File(video_thumbnail_path!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 35),
              // 提交按钮
            ElevatedButton(
              onPressed: () {
                // 上传视频逻辑
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), backgroundColor: const Color.fromARGB(255, 188, 134, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ), // 按钮颜色
              ),
              child: const Text(
                'Upload',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      )
    );
  }
}