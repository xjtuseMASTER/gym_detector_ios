import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/record_dynamic_page.dart';
import 'package:gym_detector_ios/module/person.dart';
class DynamiclistView extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final List<String> Dynamic_bar_Name = ['Likes', 'Release', 'Collects'];
  // ignore: non_constant_identifier_names
  final List<String> Dynamic_bar_Images = [
    'assets/bar_images/tbar1.png',
    'assets/bar_images/tbar2.png',
    'assets/bar_images/tabr3.png',
  ];
  // ignore: non_constant_identifier_names
  final List<String> Dynamic_bar_Desciption = [
    'Used To Like ',
    'Used To Release',
    'Used To Collect',
  ];
  final List<bool> foodHighlights = [true, true, true]; // 示例
  final Person getperson;//目标访问用户
  DynamiclistView({required this.getperson});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
           Navigator.push(
              context,
             MaterialPageRoute(builder: (context)=>RecordDynamicPage(index: index, title: Dynamic_bar_Desciption[index],getperson: getperson,)));
          },
         child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 阴影颜色
                  spreadRadius: 2, // 扩散半径
                  blurRadius: 5, // 模糊半径
                  offset: const Offset(0, 3), // 偏移量 (x, y)
                ),
              ],
               gradient: LinearGradient(
                begin: Alignment.bottomLeft, // 左下角
                end: Alignment.topRight,     // 右上角
                colors: [
                   const Color.fromARGB(255, 205, 139, 217).withOpacity(0.4), // 渐变的终止颜色
                  const Color.fromARGB(255, 183, 209, 230).withOpacity(0.4), // 渐变的起始颜色
                ],
              ),
            ),
            // 增加整体左右的内边距
            padding: const EdgeInsets.symmetric(horizontal: 15), // 设置容器的左右内边距
            child: Row(
              children: [
                // 圆形图片
                Container(
                  // 调整图片距离卡片左边的距离
                  margin: const EdgeInsets.only(right: 20), // 调整图片与文字之间的距离
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // 设置为圆形
                    image: DecorationImage(
                      image: AssetImage(Dynamic_bar_Images[index]),
                      fit: BoxFit.cover, // 图片填充方式
                    ),
                  ),
                ),
                // 卡片内容
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, left: 15, right: 10), // 调整文字内边距
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Dynamic_bar_Name[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 15,
                            )
                          ],
                        ),
                        Text(
                          Dynamic_bar_Desciption[index],
                          style: TextStyle(
                            color: foodHighlights[index]
                                ? const Color.fromARGB(255, 198, 127, 229) // 使用高亮颜色
                                : Colors.grey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
        separatorBuilder: (_, index) => const SizedBox(
          height: 15,
        ),
        itemCount: Dynamic_bar_Name.length,
      ),
    );
  }
}