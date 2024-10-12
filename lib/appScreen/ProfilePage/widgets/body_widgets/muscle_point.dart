//肌肉点绘制和卡片绘制
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/body_widgets/muscle_line_painter.dart';
import 'package:gym_detector_ios/module/muscle.dart';

class MusclePoint extends StatefulWidget {
  final Muscle muscle;
  final Offset position;

  MusclePoint({required this.muscle, required this.position});

  @override
  _MusclePointState createState() => _MusclePointState();
}

class _MusclePointState extends State<MusclePoint> {
  late double cardWidth;
  late double cardHeight;

  @override
  void initState() {
    super.initState();
    // 在初始化时计算卡片的宽度和高度
    _calculateCardSize();
  }

  void _calculateCardSize() {
    // 使用 TextPainter 计算文本的尺寸
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.muscle.name,
        style: TextStyle(fontSize: 16.0),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    // 布局计算尺寸
    textPainter.layout();

    // 卡片宽度等于文本宽度加上 padding
    cardWidth = textPainter.width + 8;  // padding left + right
    cardHeight = textPainter.height + 8; // padding top + bottom
  }

  @override
  Widget build(BuildContext context) {
    // 根据卡片的宽度和高度来确定最终的位置
    final Offset LineendPosition = widget.muscle.index.isOdd
        ? Offset(widget.position.dx + 10, widget.position.dy - 70)
        : Offset(widget.position.dx - 10, widget.position.dy - 70);
    final Offset CardendPosition = widget.muscle.index.isOdd
        ? Offset(LineendPosition.dx-5, LineendPosition.dy - cardHeight)
        : Offset(LineendPosition.dx-cardWidth+15, LineendPosition.dy - cardHeight+3);

    return Stack(
      children: [
        // 绘制肌肉点
        Positioned(
          left: widget.position.dx - 5,
          top: widget.position.dy - 5,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 225, 155, 238),
              shape: BoxShape.circle,
            ),
          ),
        ),
        
        // 绘制导航线
        Positioned.fill(
          child: CustomPaint(
            painter: MuscleLinePainter(
              start: widget.position,
              end: LineendPosition,
            ),
          ),
        ),
        
        // 绘制小卡片
       Positioned(
          left: CardendPosition.dx,
          top: CardendPosition.dy,
          child: 
          GestureDetector(
            onTap:(){
              //点击肌肉小卡片弹出详细信息
            },
            child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // 添加渐变效果：从左上到右下
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 241, 94, 94),  // 渐变的起始颜色
                      Color.fromARGB(255, 236, 167, 183),  // 渐变的结束颜色
                    ],
                  ),
                  border: Border.all(color: Color.fromARGB(255, 225, 155, 238)),
                  borderRadius: BorderRadius.circular(5),
                  // 添加阴影效果
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),  // 阴影颜色
                      spreadRadius: 2,  // 阴影扩散范围
                      blurRadius: 4,    // 阴影模糊半径
                      offset: Offset(2, 2),  // 阴影的偏移量 (x, y)
                    ),
                  ],
                ),
                child: Text(
                  widget.muscle.name, 
                  style: const TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          )
        )
      ],
    );
  }
}