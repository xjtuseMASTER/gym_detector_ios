// 瀑布流图像展示widget
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/postdetail_page.dart';
import 'package:gym_detector_ios/module/person.dart';
class UsedPostGridview extends StatefulWidget {
  final Person person;//目标用户
  final Future<List<Map<String, dynamic>>> Function( String user_id,int Pagenumber) fetchMorePosts;//获取更多帖子
  UsedPostGridview({required this.person,required this.fetchMorePosts});
  _UsedPostGridviewState createState() => _UsedPostGridviewState();
}
class _UsedPostGridviewState extends State<UsedPostGridview> {
  int Pagenumber=20;//表示现在展示的视频数
  late Future<List<Map<String, dynamic>>> _futurepost;//首次构建页面的数据源
  List<Map<String, dynamic>> _posts = []; // 保存获取到的数据作为真正的数据源
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;//是否加载
  bool _isRefreshing = false;//是否刷新

  @override
  void initState() {
    super.initState();
    _futurepost=widget.fetchMorePosts(widget.person.ID,Pagenumber);//第一次拿取帖子构建页面
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // 上拉加载更多功能
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return; // 防止重复请求
    setState(() {
      _isLoadingMore = true;
    });
    Pagenumber=Pagenumber+20;
    List<Map<String, dynamic>> morePosts = await widget.fetchMorePosts(widget.person.ID,Pagenumber); // 获取更多的数据
    setState(() {
      _posts.addAll(morePosts); // 加载更多时追加数据
      _isLoadingMore = false;
    });
  }

  // 监听滚动事件，判断是否需要加载更多
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      _loadMorePosts(); // 当滚动到底部时加载更多
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futurepost, // 第一次加载数据
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 显示加载指示器
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // 加载完成，将数据存储到 _posts
          _posts = snapshot.data!;

          return GridView.builder(
              controller: _scrollController, // 绑定滚动控制器
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 一共两列
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0,
                childAspectRatio: 0.68, // 长宽比为0.68
              ),
              itemCount: _posts.length + (_isLoadingMore ? 1 : 0), // 数据长度 + 加载更多指示器
              itemBuilder: (context, index) {
                if (index == _posts.length && _isLoadingMore) {
                  // 显示加载指示器
                  return Center(child: CircularProgressIndicator());
                }

                final post = _posts[index]; // 当前帖子数据
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // 修剪图片为圆角半径10
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(postId: post['postId'],autherId: post['autherId']), // 传递post数据到详情页
                            ),
                          );
                        },
                        child: Flexible(
                          flex: 8,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              post['picList'][0]['picUrl'], // 显示第一张图片
                              fit: BoxFit.cover,
                              height: 205,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            post['title'].length > 8
                                ? '${post['title'].substring(0, 8)}...'
                                : post['title'],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_border_outlined,
                                      size: 14, color: Colors.yellow),
                                  const SizedBox(width: 4),
                                  Text('${post['collectsNum']}'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.favorite,
                                      size: 14, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text('${post['likesNum']}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
        } else {
          return Center(child: Text('No posts available'));
        }
      },
    );
  }
}
