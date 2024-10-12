import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/body_widgets/muscle_point.dart';
import 'package:gym_detector_ios/module/muscle.dart';

class MuscledataView extends StatefulWidget {
  @override
  _MuscledataViewState createState() => _MuscledataViewState();
}

class _MuscledataViewState extends State<MuscledataView> {
  final List<Muscle> muscles = Muscle.customMuscleList();
  @override
  Widget build(BuildContext context) {
       return  Scaffold(
      appBar: AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Your Musle Data', 
        style: TextStyle(
           color: Color(0xFF755DC1),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth;
            double containerHeight = constraints.maxHeight;

            // 计算缩放后的图片尺寸，保持原始宽高比
            double imageAspectRatio = 467 / 1087;
            double imageWidth, imageHeight;

            if (containerWidth / containerHeight > imageAspectRatio) {
              imageHeight = containerHeight;
              imageWidth = imageHeight * imageAspectRatio;
            } else {
              imageWidth = containerWidth;
              imageHeight = imageWidth / imageAspectRatio;
            }

            double widthRatio = imageWidth / 467; // 原始图片宽度 467
            double heightRatio = imageHeight / 1087; // 原始图片高度为 1087

            double offsetX = (containerWidth - imageWidth) / 2;
            double offsetY = (containerHeight - imageHeight) / 2;

            return Stack(
              children: [
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: Image.asset(
                    'assets/bodydata_images/sample1.png', // 人体模型
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                //绘制肌肉点及其卡片
                ...muscles.map((muscle) {
                  double x = muscle.position.dx * widthRatio + offsetX;
                  double y = muscle.position.dy * heightRatio + offsetY;
                  return MusclePoint(
                    muscle: muscle,
                    position: Offset(x, y),
                  );
                }).toList(),
              ]
         
           );
          }
        )
      )
       );
  }
}
