//简要个人信息展示类

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_details.dart';
import 'package:gym_detector_ios/module/person.dart';
class PersonCard extends StatelessWidget{
  Person person;
  PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
         margin: const EdgeInsets.only(top: 20,left: 8,right: 8),//外边距
        padding: const EdgeInsets.only(top: 25,bottom: 10,left: 25,right: 25),//内边距
        decoration: BoxDecoration(
        color: Colors.white, // 背景色
        borderRadius: BorderRadius.circular(15), // 圆角边框
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // 阴影颜色
            spreadRadius: 1, // 阴影扩散半径
            blurRadius: 10,  // 模糊半径，值越大阴影越模糊
            offset: const Offset(0, 5), // 阴影偏移量，可以控制阴影的位置
          ),
        ],
         gradient: LinearGradient( //设置渐变效果
            begin: Alignment.bottomLeft, // 左下角
            end: Alignment.topRight,     // 右上角
            colors: [
              const Color.fromARGB(255, 176, 205, 245).withOpacity(0.5), // 渐变的起始颜色
              const Color.fromARGB(255, 229, 151, 242).withOpacity(0.5), // 渐变的终止颜色
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,//名称
                      style:
                          const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              person.sex, //性别
                              style: const TextStyle(color: Colors.white),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonDetailsPage(
                                  person: person,
                                    )));
                  },              
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    person.profile_photo,//用户头像
                    width: 80,
                  ),
                )
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(person.sign_name, style: const TextStyle(fontSize: 16)),//个性签名
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color.fromARGB(255, 224, 89, 89)), //累计点赞数
                    Text(
                      person.likes.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ],
            )
          ],
        ));
  }




}