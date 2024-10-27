//废弃
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/others_profile_page.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';

class CommentSection extends StatefulWidget {
  final String post_id;
  final List<Map<String, dynamic>> commentlist;
  CommentSection({required this.post_id, required this.commentlist});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  // 控制回复的展开/收起
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    isExpandedList = List<bool>.filled(widget.commentlist.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true, // 避免无限扩展
              physics: ClampingScrollPhysics(), // 允许滚动
              itemCount: widget.commentlist.length,
              itemBuilder: (context, index) {
                final comment = widget.commentlist[index];
                final replies = comment['replies'] ?? []; // 获取该评论的回复

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          // 点击头像导航至别人的个人主页
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OthersProfilePage(user_id: comment['authorId']),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: comment['authorAvatar'] == ''
                              ? const AssetImage('assets/images/NullPhoto.png') as ImageProvider
                              : NetworkImage(comment['authorAvatar']) as ImageProvider,
                        ),
                      ),
                      title: Text(
                        comment['authorName'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['content'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _showReplyInput(context, index); // 显示回复输入框
                                },
                                child: Text('reply'),
                              ),
                              if (replies.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isExpandedList[index] = !isExpandedList[index]; // 切换展开/收起
                                    });
                                  },
                                  child: Text(
                                      isExpandedList[index] ? 'Pick up' : 'Expand ${replies.length} more'),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(comment['time']),
                    ),
                    // 展开评论表
                    if (isExpandedList[index])
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: replies.length,
                          itemBuilder: (context, replyIndex) {
                            final reply = replies[replyIndex];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: reply['authorAvatar'] == ''
                                    ? const AssetImage('assets/images/NullPhoto.png') as ImageProvider
                                    : NetworkImage(reply['authorAvatar']) as ImageProvider,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reply['authorName'],
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                                  ),
                                  Text(
                                    'reply to: ${reply['replyTo']}',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reply['content'],
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _showReplyInput(context, index); // 显示回复输入框
                                        },
                                        child: Text('reply'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Text(reply['time']),
                            );
                          },
                        ),
                      ),
                    const Divider(
                      color: Color.fromARGB(255, 234, 207, 246),
                      thickness: 1.0,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 显示回复输入框的功能
  void _showReplyInput(BuildContext context, int commentIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String replyContent = '';
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  replyContent = value;
                },
                decoration: InputDecoration(
                  labelText: '回复内容',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (replyContent.isNotEmpty) {
                    setState(() {
                      Map<String, dynamic> newReply = {
                        "commentId": "",
                        "authorId": GlobalUser().user!.user_id,
                        "authorName": GlobalUser().user!.user_name,
                        "authorAvatar": GlobalUser().user!.avatar,
                        "content": replyContent,
                        "time": "2024-04-16 14:20:08",
                        "replyTo": "sunt elit ut"
                      };
                      widget.commentlist[commentIndex]['replies'] ??= [];
                      widget.commentlist[commentIndex]['replies'].add(newReply);
                    });
                    Navigator.pop(context); // 关闭输入框
                  }
                },
                child: Text('发送'),
              ),
            ],
          ),
        );
      },
    );
  }
}