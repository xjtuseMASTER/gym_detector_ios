//简要个人信息展示类

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_details.dart';
import 'package:gym_detector_ios/module/person.dart';
// ignore: must_be_immutable
class PersonCard extends StatelessWidget{
  Person person;
  bool isOneself;
  PersonCard({required this.person,required this.isOneself});

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
                         Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 240, 205, 250).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              person.birthdate, //性别
                              style: const TextStyle(color: Colors.black87),
                            )),
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  onTap: (){
                    if(isOneself){ //只有用户本身才能点击进入详细个人主页
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonDetailsPage(
                                  person: person,
                                    )));
                  }},              
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    person.profile_photo, // 用户头像的 URL
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error); // 如果加载图片失败，显示一个错误图标
                    },
                  )
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
                    SizedBox(width: 5),
                    Text(
                      person.likes.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(
                      width: 15,
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 关注数
                GestureDetector(
                  onTap: (){
                    //点击进入关注页面
                  },
                  child: Row(
                    children: [
                      const Text( 
                        'Follows:',
                        style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text( 
                        person.follow.toString(),
                        style:  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      ],
                  ),
                ),
                SizedBox(width: 70),
                // 粉丝数
                GestureDetector(
                  onTap: (){
                    //点击进入粉丝页面
                  },
                  child: Row(
                    children: [
                      const Text( 
                        'Fans:',
                        style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text( 
                        person.fans.toString(),
                        style:  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      ],
                  ),
                )

                
              ],
            )

          ],
        ));
  }




}