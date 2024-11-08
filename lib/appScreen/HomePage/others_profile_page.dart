// 点击头像查看别人的个人主页
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/dynamiclist_view.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/bar_widgets/barlist.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/other_person_card.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/person_widgets/person_card.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/Leadline_bar.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:gym_detector_ios/widgets/reminder_dialog.dart';

// ignore: must_be_immutable
class OthersProfilePage  extends StatefulWidget{
  final bool isOneself=false;
  final String user_id;//被访问人的id
  bool isFollowed=false;//是否已经关注此人进入这个界面之后拿去数据
  OthersProfilePage({required this.user_id}); 
_OthersProfilePageState createState()=>_OthersProfilePageState();

}

class _OthersProfilePageState extends State<OthersProfilePage>{
  var selected = 0;
  final pageController = PageController();
    late Future<Person?> _personFuture;
  void initState() {
    super.initState();
    _personFuture=fetchUserData();
  }

  // 异步获取数据
  Future<Person?> fetchUserData() async {
    try {
      // 获取数据
      final Response = await customHttpClient.get(Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/user/getuser').replace(
         queryParameters: {
            'user_id': widget.user_id,
            'own_id':GlobalUser().user!.user_id
          }
      ));
      if (Response.statusCode == 200) {
         final jsonResponse = json.decode(Response.body);
         final person=Person(user_name: jsonResponse['data']['user_name'], selfInfo: jsonResponse['data']['selfIntro'], gender: jsonResponse['data']['gender'],
          avatar: jsonResponse['data']['avatar'], user_id:  jsonResponse['data']['user_id'], password:  jsonResponse['data']['password'], email:  jsonResponse['data']['email'], likes_num:  jsonResponse['data']['likes_num'], 
          birthday:  jsonResponse['data']['birthday'], collects_num:  jsonResponse['data']['collects_num'], followers_num:  jsonResponse['data']['followers_num']);
          print(person.user_name);
          return person;

         //widget.isFollowed=
      } else {
      // 根据不同状态码显示错误信息
      String errorMessage;
      if (Response.statusCode == 404) {
        errorMessage = 'Resource not found';
      } else if (Response.statusCode == 500) {
        errorMessage = 'Server error';
      } else if (Response.statusCode == 403) {
        errorMessage = 'Permission denied';
      } else {
        errorMessage = 'Unknown error';
      }

     
      CustomSnackBar.showFailure(context, errorMessage);
    }
    } catch (e) {
      return null ;
    }
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Person?>(
        future: _personFuture,  // 异步顺序加载数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}')); // 错误处理
          } else if (snapshot.hasData && snapshot.data!=null) {
            final person = snapshot.data!;
            return  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top, left: 25, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          //返回之前页面
                          Navigator.pop(context);
                        },
                        child: LeadlineBar(geticon: Icons.arrow_back,getcolor: Color.fromARGB(255, 206, 163, 219))
                      ),
                      GestureDetector(
                        onTap: ()async{
                          //弹窗确认关注与否
                          await comfirmOperateFollow();
                          setState(() {
                            widget.isFollowed?person.followers_num++:person.followers_num--;
                          });
                        },
                        child: LeadlineBar(geticon: widget.isFollowed?Icons.done:Icons.add,getcolor: Color.fromARGB(255, 206, 163, 219))
                      ),
                    ],
                  ),
                ),
                OtherPersonCard(person1: person),
                BarList(
                  selected: selected,
                  callback: (int index) {
                    setState(() {
                      selected = index;
                    });
                  },
                  isOneself: false,
                ),
                Expanded(
                  child: IndexedStack(
                    index: selected,
                    children: [
                      // 显示第一个选项的内容
                      DynamiclistView(getperson: person,isOneself: false),
                    ],
                  ) 
                
                ),
              ],
            );
          } else {
            return Center(child: Text('Failed to load data')); // 如果数据加载失败，显示错误提示
          }
        },
      ),
    );
  }
  //关注/取消关注
  Future<void> OpeateFollow()async{
    ReminderDialog(Oncomfirm:comfirmOperateFollow,information:widget.isFollowed? 'Do you want you unfollow him?':'Do you want you follow him?').show(context);//显示弹窗

  }
  //确认关注
  Future<void> comfirmOperateFollow()async {
     // 这里的Oncomfirm为代传入的向后端更新数据的接口

     try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Operaing...');

    // 发送请求
    final response = await customHttpClient.get(
        Uri.parse(widget.isFollowed?'http://127.0.0.1:4523/m1/5245288-4913049-default/follower/unfollow':'http://127.0.0.1:4523/m1/5245288-4913049-default/follower/follow').replace(
          queryParameters: {
            'user_id': GlobalUser().getUser()!.user_id, // 关注者id
            'to_user_id':widget.user_id //被关注者id
          },
        ),
      );

    if (response.statusCode == 200) {
      // 请求成功
      //  提取 data 部分
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Operated Successfully');
    } else {
      // 请求失败，根据状态码显示不同的错误提示
      String errorMessage;
      if (response.statusCode == 404) {
        errorMessage = 'Resource not found';
      } else if (response.statusCode == 500) {
        errorMessage = 'Server error';
      } else if (response.statusCode == 403) {
        errorMessage = 'Permission denied';
      } else {
        errorMessage = 'Unknown error';
      }

      // 隐藏加载对话框，显示错误提示框
      LoadingDialog.hide(context);
       CustomSnackBar.showFailure(context,errorMessage);
    }
  } catch (e) {
    // 捕获网络异常，如超时或其他错误
    LoadingDialog.hide(context);
     CustomSnackBar.showFailure(context,'Network Error: Cannot fetch data');
  }
     setState(() {
      widget.isFollowed=!widget.isFollowed;//改为关注状态并进行状态更新
    });
  }
  //  取消关注
  

  }