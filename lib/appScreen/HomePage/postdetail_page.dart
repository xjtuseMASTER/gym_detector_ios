
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/appScreen/HomePage/others_profile_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/profile_page.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/api/Post/post_api.dart';
import 'package:gym_detector_ios/widgets/networkerror_screen.dart';
import 'package:gym_detector_ios/widgets/no_data_screen.dart';

class DetailPage extends StatefulWidget {
  final String postId; //帖子Id
  final String authorId; //作者Id
  DetailPage({required this.postId, required this.authorId});
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> _postFuture;
  Map<String,dynamic> post={};
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  List<Map<String, dynamic>> commentlist = [];
  bool isCollect = false; // 收藏状态
  bool isFavorite = false; //点赞状态
  double collect_iconScale = 1.3; // 收藏按钮初始缩放比例
  double favorite_iconScale = 1.3; // 点赞按钮初始缩放比例
  int currentImageIndex = 0;
  String CommentId='';
  bool _isFirstLoad = true;
  // 控制回复的展开/收起
  List<bool> isExpandedList = [];
  //数据集结果
  final results=[];
  @override
  void initState() {
    super.initState();
    _postFuture = PostApi.fetchPostData({
            'post_id': widget.postId,
            'user_id': GlobalUser().user!.user_id
          });
    _postFuture.then((post_result){
      post=post_result;
      return post_result;
    });
    isExpandedList = List<bool>.filled(
            10000, false,
            growable: true);
    _commentsFuture = PostApi.fetchCommentData({'post_id': widget.postId}).then((comments) {
      setState(() {
        commentlist = comments;  // 设置初始的评论数据
      });
      return comments;
    });
   
  }

  //计算评论数量
  int getCommentNumber(List<Map<String,dynamic>> cl) {
    int temp = cl.length;
    for (var comment in cl) {
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
  Map<String, dynamic> generateComment(String content,String commentId) {
    return {
      "commentId": commentId,
      "authorId": GlobalUser().getUser()!.user_id,
      "authorName": GlobalUser().getUser()!.user_name,
      "authorAvatar": GlobalUser().getUser()!.avatar,
      "content": content,
      "time": "Just now",
      "replies": []
    };
  }

  //生成回复对象
  Map<String, dynamic> generateReply(String content, String replyTo,String CommentId) {
    return {
      "commentId": CommentId,
      "authorId": GlobalUser().getUser()!.user_id,
      "authorName": GlobalUser().getUser()!.user_name,
      "authorAvatar": GlobalUser().getUser()!.avatar,
      "content": content,
      "time": "Just now",
      "replyTo": replyTo
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty|| snapshot.data!['postId'] == null) {
            return NetworkErrorScreen();
          } 
          //数据加载正常
          else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 220, 179, 235),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        post['authorId']==GlobalUser().user!.user_id?
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(selected: 0),
                          ),
                        ):
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OthersProfilePage(
                              user_id: post['authorId'],
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: post['authorAvatar'] == null
                            ? const AssetImage('assets/images/NullPhoto.png')
                                as ImageProvider
                            : CachedNetworkImageProvider(post['authorAvatar'])
                                as ImageProvider,
                        radius: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      post['authorName']==null?'None':post['authorName'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 450,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: post['picList'].length,
                            itemBuilder: (context, index) {
                            return 
                            CachedNetworkImage(
                            imageUrl: post['picList'][index]['picUrl'],
                            height: 205,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _isFirstLoad
                                ? Center(child: CircularProgressIndicator())
                                : SizedBox(), // 不显示加载器
                            imageBuilder: (context, imageProvider) {
                              // 确保在构建完成后调用 setState
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_isFirstLoad) {
                                  setState(() {
                                    _isFirstLoad = false;
                                  });
                                }
                              });
                              return Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                height: 205,
                                width: double.infinity,
                              );
                            },
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/NetworkError.png',
                              height: 205,
                              width: double.infinity,
                            ),
                          );
                            },
                            onPageChanged: (index) {
                            setState(() {
                              currentImageIndex = index;
                            });
                            // 切换图片时处理小红点显示
                          },
                          ),
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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['title'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            post['content'],
                            style: TextStyle(fontSize: 16),
                          ),
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
                                            post['isLike']
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border, // 根据状态显示图标
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await PostApi.operateFavorite(context,post['isLike'], {
                                                'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
                                                'post_id': widget.postId
                                              });
                                            setState(() {
                                              favorite_iconScale =
                                                  3; // 设置放大效果
                                            });
                                            // 动画结束后将图标缩回原始大小
                                            Future.delayed(
                                                Duration(milliseconds: 200),
                                                () {
                                              setState(() {
                                                favorite_iconScale =
                                                    1.3; // 缩回原始大小
                                                post['isLike']?post['likesNum']--:post['likesNum']++;
                                                post['isLike']=!post['isLike'];
                                              });
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Text( quantityCarry(post['likesNum'])),
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
                                            post['isCollect']
                                                ? Icons.star
                                                : Icons.star_border, // 根据状态显示图标
                                            color: Colors.yellow,
                                          ),
                                          onPressed: () async {
                                            //上传后端处理逻辑
                                            await PostApi.operateCollect(context,  post['isCollect'], {
                                              'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
                                              'post_id': widget.postId
                                            });
                                            setState(() {
                                              collect_iconScale = 3; // 设置放大效果
                                            });
                                            // 动画结束后将图标缩回原始大小
                                            Future.delayed(
                                                Duration(milliseconds: 200),
                                                () {
                                              setState(() {
                                                collect_iconScale =
                                                    1.3; // 缩回原始大小
                                                post['isCollect']? post['collectsNum']--:post['collectsNum']++;
                                                 post['isCollect']=!  post['isCollect'];
                                              });
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Text(quantityCarry(post['collectsNum'])),
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
                                  Text(post['creatTime'].substring(0,16))
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          const Text(
                            'Comments',
                            style: TextStyle(
                              color: Color(0xFF755DC1),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Comments section
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _commentsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                // 当异步任务正在加载时，显示加载指示器
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                  ],
                                );
                              } else if (snapshot.hasData ) {
                              if(commentlist.length==0)
                              {return NoDataScreen(message: 'No comments yet. Be the first to comment!',);}
                              else{
                              return  Column(
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
                                              radius: 25,
                                              backgroundImage: (comment['authorAvatar'] == null || comment['authorAvatar'].isEmpty)
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
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
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
                                                          : '${replies.length} more',
                                                          overflow: TextOverflow.ellipsis,
                                                          ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: comment['time'] == "Just now" ? Text("Just now"): Text(comment['time'].substring(0,16),overflow: TextOverflow.ellipsis,),
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
                                                          child:  CircleAvatar(
                                                          backgroundImage: (reply['authorAvatar'] == null || reply['authorAvatar'] == '')
                                                              ? const AssetImage('assets/images/NullPhoto.png') as ImageProvider
                                                              : NetworkImage(reply['authorAvatar'])as ImageProvider,
                                                        ),
                                                        ),
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            reply['authorName'],
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          const Text(
                                                            'To:',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .grey),

                                                          ),
                                                          Text(
                                                            reply['replyTo'],
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .grey),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(reply['content'],
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                                        overflow: TextOverflow.ellipsis, 
                                                                        maxLines: 2, 
                                                                          ),
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
                            );
                              }
                              } else {
                                // 如果请求成功并且数据不为空，显示内容
                                return NetworkErrorScreen();
                              }
                            },
                          )
                          //评论区

                        ],
                      ),
                    ),
                  ),
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
                          PostApi.replyToPost(context,body).then((result) {
                            if (mounted) {
                              CommentId=result;
                              Navigator.pop(context);
                            }
                          });
                          setState(() {
                            commentlist.insert(
                                0, generateComment(replyController.text,CommentId));
                          });
                        } else {
                          PostApi.replyToComment(context, body).then((result) {
                            if (mounted) {
                              CommentId=result;
                              Navigator.pop(context);
                            }
                          });
                          setState(() {
                            commentlist[index]['replies'].insert(0,
                                generateReply(replyController.text, replyTo,CommentId));
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
