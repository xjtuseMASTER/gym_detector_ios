//嵌套评论区
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/others_profile_page.dart';

class CommentSection extends StatefulWidget {
  final Map post;

  CommentSection({required this.post});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  // 控制回复的展开/收起
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    // 初始化展开状态为 false
    isExpandedList = List.generate(widget.post['comments'].length, (index) => false);
  }

  // 用于生成每个评论和嵌套的回复列表
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // 避免无限扩展
      physics: NeverScrollableScrollPhysics(), // 禁止内部滚动
      itemCount: widget.post['comments'].length,
      itemBuilder: (context, index) {
        final comment = widget.post['comments'][index];
        final replies = comment['replies'] ?? []; // 获取该评论的回复
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => OthersProfilePage(person: comment['author']),
                  ));
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(comment['author'].profile_photo),
                ),
              ),
              title: Text(comment['author'].name,style:TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment['content'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
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
                          child: Text(isExpandedList[index] ? 'Pick up' : 'Exapnd ${replies.length} more '),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: Text(comment['time']),
            ),
            if (isExpandedList[index])
              Padding(
                padding: const EdgeInsets.only(left: 40.0), // 缩进以显示嵌套回复
                child: 
                Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: replies.length,
                  itemBuilder: (context, replyIndex) {
                    final reply = replies[replyIndex];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(reply['author'].profile_photo),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text( reply['author'].name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.black)),
                          Text('reply to: ${reply['reply_to']}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.grey),)
                          ]
                        
                        ),
                      subtitle:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Text( reply['content'],style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
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
                 ]
              )
              ),
               const Divider(
                    color: Color.fromARGB(255, 234, 207, 246), // 线的颜色
                    thickness: 1.0,     // 线的厚度
                  ),
          ],
        );
      },
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
                      widget.post['comments'][commentIndex]['replies'] ??= [];
                      widget.post['comments'][commentIndex]['replies'].add({
                        'author': {
                          'name': '当前用户',
                          'profile_photo': 'assets/current_user.jpg',
                        },
                        'reply_to': widget.post['comments'][commentIndex]['author']['name'],
                        'content': replyContent,
                        'time': '刚刚',
                      });
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
