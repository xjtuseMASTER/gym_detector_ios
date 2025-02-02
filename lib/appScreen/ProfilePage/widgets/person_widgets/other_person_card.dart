//别人的个人卡片
//简要个人信息展示类

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_details.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
// ignore: must_be_immutable
class OtherPersonCard extends StatefulWidget{
  Person person1;//不使用
  OtherPersonCard({required this.person1});
  _OtherPersonCardState createState()=>_OtherPersonCardState();
}

class _OtherPersonCardState extends State<OtherPersonCard>{
  @override
  Widget build(BuildContext context) {
    Person? person=widget.person1;
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
                      person!.user_name.length>10? '${person!.user_name.substring(0,5)}...':person!.user_name,//名称
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
                              person!.gender, //性别
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
                              person!.birthday, //性别
                              style: const TextStyle(color: Colors.black87),
                            )),
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  onTap: (){
                },              
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: 
                  person!.avatar==null?
                   Image.asset(
                    'assets/images/NullPhoto.png', // 用户头像的 URL
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error); // 如果加载图片失败，显示一个错误图标
                    },
                  ):
                  Image.network(
                    person!.avatar, // 用户头像的 URL
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
                Text(person!.selfInfo.length>13?'${person!.selfInfo.substring(0,13)}...':person!.selfInfo, style: const TextStyle(fontSize: 16)),//个性签名
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color.fromARGB(255, 224, 89, 89)), //累计点赞数
                    SizedBox(width: 5),
                    Text(
                      person!.likes_num.toString(),
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
                        person!.collects_num.toString(),
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
                        person!.followers_num.toString(),
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