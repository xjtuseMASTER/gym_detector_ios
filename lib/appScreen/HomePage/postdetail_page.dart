import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/others_profile_page.dart';
import 'package:gym_detector_ios/appScreen/HomePage/widgets/comment_selection.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';

class DetailPage extends StatefulWidget {
  final String postId; //帖子Id
  final String authorId; //作者Id
  DetailPage({required this.postId, required this.authorId});
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> _postFuture;
  late Future<List<Map<String, dynamic>>> _commentlist;
  late Future<Map<String, dynamic>> _combinedFuture;
  List<Map<String, dynamic>> commentlist = [];
  bool isCollect = false; // 收藏状态
  bool isFavorite = false; //点赞状态
  double collect_iconScale = 1.3; // 收藏按钮初始缩放比例
  double favorite_iconScale = 1.3; // 点赞按钮初始缩放比例
  int currentImageIndex = 0;
  // 控制回复的展开/收起
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _postFuture = fetchPostData(); // 初始化时启动异步加载数据
    _commentlist = fetchCommentData();
    _combinedFuture = combineFutures();
  }

  //计算评论数量
  int getCommentNumber() {
    int temp = commentlist.length;
    for (var comment in commentlist) {
      temp += (comment['replies'].length as int);
    }
    return temp;
  }

  //数量的单位进制
  String quantityCarry(int num) {
    if (num < 1000) {
      return "${num}";
    } else if (num > 1000 && num < 10000) {
      return "${num / 1000} k";
    } else {
      return "${num / 10000} w";
    }
  }

  //生成评论对象
  Map<String, dynamic> generateComment(String content) {
    return {
      "commentId": "",
      "authorId": GlobalUser().getUser()!.user_id,
      "authorName": GlobalUser().getUser()!.user_name,
      "authorAvatar": GlobalUser().getUser()!.avatar,
      "content": content,
      "time": "Just now",
      "replies": []
    };
  }

  //生成回复对象
  Map<String, dynamic> generateReply(String content, String replyTo) {
    return {
      "commentId": "",
      "authorId": GlobalUser().getUser()!.user_id,
      "authorName": GlobalUser().getUser()!.user_name,
      "authorAvatar": GlobalUser().getUser()!.avatar,
      "content": content,
      "time": "Just now",
      "replyTo": replyTo
    };
  }

  //点赞和取消点赞
  Future<void> operateFavorite(String post_id) async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse(isFavorite
                ? '${Http.httphead}/post_like/unlike'
                : '${Http.httphead}/post_like/like')
            .replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
            'post_id': post_id
          },
        ),
      );
      if (response.statusCode == 200) {
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

        // 显示错误提示框
        CustomSnackBar.showFailure(context, errorMessage);
      }
    } catch (e) {
      // 捕获网络异常，如超时或其他错误
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }

  //收藏和取消收藏的操作
  Future<void> operateCollect(String post_id) async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse(isCollect
                ? '${Http.httphead}/post_collect/uncollect'
                : '${Http.httphead}/post_collect/collect')
            .replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
            'post_id': post_id
          },
        ),
      );
      if (response.statusCode == 200) {
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

        // 显示错误提示框
        CustomSnackBar.showFailure(context, errorMessage);
      }
    } catch (e) {
      // 捕获网络异常，如超时或其他错误
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }

  //合成同一个异步数据集

  Future<Map<String, dynamic>> combineFutures() async {
    // 使用 Future.wait 同时等待 _postFuture 和 _commentlist 完成
    final results = await Future.wait([
      _postFuture,
      _commentlist,
    ]);
    // 将结果组合成一个 Map
    return {
      'post': results[0], // _postFuture 的结果
      'commentList': results[1], // _commentlist 的结果
    };
  }

  //异步获取帖子数据
  Future<Map<String, dynamic>> fetchPostData() async {
    try {
      final response = await customHttpClient.get(
        Uri.parse(
                '${Http.httphead}/post/details')
            .replace(
          queryParameters: {
            'post_id': widget.postId,
            'user_id': GlobalUser().user!.user_id
          },
        ),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse = json.decode(decodedBody);
        return jsonResponse['data'] ?? {}; // 返回数据
      } else {
        throw Exception('Failed to fetch post data');
      }
    } catch (e) {
      print('Error: $e');
      return {}; // 返回空数据以避免错误
    }
  }

  // 异步获取评论数据
  Future<List<Map<String, dynamic>>> fetchCommentData() async {
    try {
      final response = await customHttpClient.get(
        Uri.parse(
                '${Http.httphead}/comment/commentdetail')
            .replace(
          queryParameters: {'post_id': widget.postId},
        ),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse = json.decode(decodedBody);
        isExpandedList = List<bool>.filled(
            jsonResponse['data'].length, false,
            growable: true);
        return List<Map<String, dynamic>>.from(
            jsonResponse['data'] ?? []);
      } else {
        print(
            'Failed to fetch Comment data with status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Error fetching comment data: $e");
      return [];
    }
  }

//对帖子评论
  Future<void> replyToPost(Map<String, dynamic> body) async {
    LoadingDialog.show(context, 'Replying...'); // 显示加载指示器

    try {
      // 发送 POST 请求到后端
      final response = await customHttpClient.post(
        Uri.parse(
            '${Http.httphead}/comment/comment'),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        CustomSnackBar.showSuccess(context, "reply successfully!");
      } else {
        // 根据不同状态码显示错误信息
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

        LoadingDialog.hide(context);
        CustomSnackBar.showFailure(context, errorMessage);
      }
    } catch (e) {
      // 捕获网络异常并显示错误提示
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }

//回复评论
  Future<void> replyToComment(Map<String, dynamic> body) async {
    LoadingDialog.show(context, 'Replying...'); // 显示加载指示器

    try {
      // 发送 POST 请求到后端
      final response = await customHttpClient.post(
        Uri.parse(
            '${Http.httphead}/comment/sub_comment'),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        CustomSnackBar.showSuccess(context, "reply successfully!");
      } else {
        // 根据不同状态码显示错误信息
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

        LoadingDialog.hide(context);
        CustomSnackBar.showFailure(context, errorMessage);
      }
    } catch (e) {
      // 捕获网络异常并显示错误提示
      LoadingDialog.hide(context);
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 数据加载中时显示加载指示器
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 错误处理
            return Center(child: Text('Failed to load post data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // 如果数据为空
            return Center(child: Text('No data found'));
          } else {
            // 数据加载完成后显示内容
            final combinedFuture = snapshot.data!;
            final post = combinedFuture['post'];
            commentlist = combinedFuture['commentList'];

            return Scaffold(
              appBar: AppBar(
                backgroundColor:
                    const Color.fromARGB(255, 220, 179, 235), // 白色背景
                elevation: 0, // 取消阴影
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black), // 返回按钮
                  onPressed: () {
                    Navigator.pop(context); // 返回首页
                  },
                ),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 导航到作者主页
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OthersProfilePage(
                                    user_id: post['authorId'])));
                      },
                      child: CircleAvatar(
                        backgroundImage: post['authorAvatar'] == ''
                            ? const AssetImage('assets/images/NullPhoto.png')
                                as ImageProvider
                            : NetworkImage(post['authorAvatar'])
                                as ImageProvider, // 帖子作者头像
                        radius: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(post['authorName'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        )), // 帖子作者呢称
                    Spacer(),
                  ],
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 帖子图片组，使用PageView显示多张图片
                  Expanded(
                    flex: 6, // 占据屏幕的上部分
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: post['picList'].length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              post['picList'][index]['picUrl'],
                              fit: BoxFit.cover,
                              height: 205,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                    'assets/images/NetworkError.png');
                              },
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              currentImageIndex = index;
                            });
                            // 切换图片时处理小红点显示
                          },
                        ),
                        // tu pian
                        Positioned(
                          bottom: 10,
                          left: MediaQuery.of(context).size.width / 2 - 50,
                          child: Row(
                            children:
                                List.generate(post['picList'].length, (index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == currentImageIndex
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 包裹帖子标题、配文和评论区为可滑动区域
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 帖子标题和配文
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post['title'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                Text(post['content'],
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          //点赞评论收藏数显示
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //点赞图表和点赞数
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(
                                        begin: 1.3,
                                        end: favorite_iconScale), // 动画的起点和终点
                                    duration:
                                        Duration(milliseconds: 200), // 动画时长
                                    builder: (context, double scale, child) {
                                      return Transform.scale(
                                        scale: scale, // 根据 scale 调整大小
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border, // 根据状态显示图标
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await operateFavorite(
                                                post['postId']);

                                            setState(() {
                                              isFavorite =
                                                  !isFavorite; // 切换点赞状态
                                              favorite_iconScale =
                                                  1.7; // 设置放大效果
                                            });
                                            // 动画结束后将图标缩回原始大小
                                            Future.delayed(
                                                Duration(milliseconds: 200),
                                                () {
                                              setState(() {
                                                favorite_iconScale =
                                                    1.3; // 缩回原始大小
                                              });
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Text(isFavorite
                                      ? quantityCarry(post['likesNum'] + 1)
                                      : quantityCarry(post['likesNum'])),
                                ],
                              ),
                              SizedBox(width: 5),
                              //收藏图表和收藏数
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(
                                        begin: 1.3,
                                        end: collect_iconScale), // 动画的起点和终点
                                    duration:
                                        Duration(milliseconds: 200), // 动画时长
                                    builder: (context, double scale, child) {
                                      return Transform.scale(
                                        scale: scale, // 根据 scale 调整大小
                                        child: IconButton(
                                          icon: Icon(
                                            isCollect
                                                ? Icons.star
                                                : Icons.star_border, // 根据状态显示图标
                                            color: Colors.yellow,
                                          ),
                                          onPressed: () async {
                                            //上传后端处理逻辑
                                            await operateCollect(
                                                post['postId']);
                                            setState(() {
                                              isCollect = !isCollect; // 切换点赞状态
                                              collect_iconScale = 1.7; // 设置放大效果
                                            });
                                            // 动画结束后将图标缩回原始大小
                                            Future.delayed(
                                                Duration(milliseconds: 200),
                                                () {
                                              setState(() {
                                                collect_iconScale =
                                                    1.3; // 缩回原始大小
                                              });
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Text(isCollect
                                      ? quantityCarry(post['collectsNum'] + 1)
                                      : quantityCarry(post['collectsNum'])),
                                ],
                              ),
                              SizedBox(width: 5),
                              //评论图表和评论数
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.comment),
                                    onPressed: () {
                                      // 显示评论数逻辑
                                      final body = {
                                        "userId":
                                            GlobalUser().getUser()!.user_id,
                                        "postId": widget.postId,
                                        "content": ""
                                      };
                                      _showReplyInput(
                                          context, body, true, -1, "");
                                    },
                                  ),
                                  Text(quantityCarry(getCommentNumber())),
                                  SizedBox(width: 25),
                                  Text(post['creatTime'].substring(0,16))
                                ],
                              ),
                            ],
                          ),

                          const Divider(
                            color: Color.fromARGB(255, 234, 207, 246),
                            thickness: 1.0,
                          ),
                          const Text(
                            'Comments',
                            style: TextStyle(
                              color: Color(0xFF755DC1),
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          //平论区
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: commentlist.length,
                                  itemBuilder: (context, index) {
                                    final comment = commentlist[index];
                                    final replies = comment['replies'] ?? [];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          leading: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OthersProfilePage(
                                                          user_id: comment[
                                                              'authorId']),
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              backgroundImage: comment[
                                                          'authorAvatar'] ==
                                                      ''
                                                  ? const AssetImage(
                                                          'assets/images/NullPhoto.png')
                                                      as ImageProvider
                                                  : NetworkImage(comment[
                                                          'authorAvatar'])
                                                      as ImageProvider,
                                            ),
                                          ),
                                          title: Text(
                                            comment['authorName'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment['content'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      final body = {
                                                        "userId": GlobalUser()
                                                            .getUser()!
                                                            .user_id,
                                                        "postId": widget.postId,
                                                        "commentId":
                                                            comment[
                                                                'commentId'],
                                                        "content": ""
                                                      };
                                                      _showReplyInput(
                                                          context,
                                                          body,
                                                          false,
                                                          index,
                                                          comment[
                                                              'authorName']);
                                                      isExpandedList[index] =
                                                          true;
                                                    },
                                                    child: Text('reply'),
                                                  ),
                                                  if (replies.isNotEmpty)
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          isExpandedList[
                                                                  index] =
                                                              !isExpandedList[
                                                                  index];
                                                        });
                                                      },
                                                      child: Text(isExpandedList[
                                                              index]
                                                          ? 'Pick up'
                                                          : 'Expand ${replies.length} more'),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: comment['time'] == "Just now" ? Text("Just now"): Text(comment['time'].substring(0,16)),
                                        ),
                                        // 展开评论表
                                        if (isExpandedList[index])
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0), // 适度缩进
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: ClampingScrollPhysics(),
                                              itemCount: replies.length,
                                              itemBuilder:
                                                  (context, replyIndex) {
                                                final reply =
                                                    replies[replyIndex];
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ListTile(
                                                      contentPadding: EdgeInsets
                                                          .zero, // 去除默认内边距
                                                      leading: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    OthersProfilePage(
                                                                        user_id:
                                                                            reply['authorId']),
                                                              ),
                                                            );
                                                          },
                                                          child: CircleAvatar(
                                                            backgroundImage: reply[
                                                                        'authorAvatar'] ==
                                                                    ''
                                                                ? const AssetImage(
                                                                        'assets/images/NullPhoto.png')
                                                                    as ImageProvider
                                                                : NetworkImage(
                                                                        reply[
                                                                            'authorAvatar'])
                                                                    as ImageProvider,
                                                          )),
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            reply['authorName'],
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Text(
                                                            reply['replyTo']
                                                                        .length >
                                                                    5
                                                                ? 'reply to: ${reply['replyTo'].substring(0, 5)}...'
                                                                : 'reply to: ${reply['replyTo']}',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(reply['content'],
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  final body = {
                                                                    "userId": GlobalUser()
                                                                        .getUser()!
                                                                        .user_id,
                                                                    "postId": widget
                                                                        .postId,
                                                                    "commentId":
                                                                        reply[
                                                                            'commentId'],
                                                                    "content":
                                                                        ""
                                                                  };
                                                                  _showReplyInput(
                                                                      context,
                                                                      body,
                                                                      false,
                                                                      index,
                                                                      reply[
                                                                          'authorName']);
                                                                },
                                                                child: Text(
                                                                    'reply'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      trailing:
                                                          reply['time'] == "Just now" ? Text("Just now"): Text(reply['time'].substring(0,16)),
                                                    ),
                                                    //分割线
                                                    Divider(
                                                      color: Color.fromARGB(
                                                          255, 234, 207, 246),
                                                      thickness: 1.0,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        //分割线
                                        const Divider(
                                          color: Color.fromARGB(
                                              255, 234, 207, 246),
                                          thickness: 1.0,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showReplyInput(BuildContext context, Map<String, dynamic> body,
      bool isComment, int index, String replyTo) {
    //isComment 代表是否是直接对帖子的评论  index：对应第几条评论，如果是直接对帖子评论的就传-1
    TextEditingController replyController = TextEditingController();
    String errorMessage = '';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: replyController,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: 'Reply...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (replyController.text.isNotEmpty) {
                        body['content'] = replyController.text;
                        if (isComment) {
                          setState(() {
                            commentlist.insert(
                                0, generateComment(replyController.text));
                            isExpandedList.add(false);
                          });
                          replyToPost(body).then((_) {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          });
                        } else {
                          setState(() {
                            commentlist[index]['replies'].insert(0,
                                generateReply(replyController.text, replyTo));
                          });
                          replyToComment(body).then((_) {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          });
                        }
                        Navigator.of(context).pop(); // 确保使用的是弹窗的 context
                      } else {
                        setModalState(
                            () => errorMessage = 'Please input first！');
                      }
                    },
                    child: Text('Send'),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
