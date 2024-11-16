//点赞，收藏，发布的记录界面

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/postdetail_page.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/services/api/Post/post_api.dart';
import 'package:gym_detector_ios/widgets/networkerror_screen.dart';
import 'package:gym_detector_ios/widgets/no_data_screen.dart';

class RecordDynamicPage extends StatefulWidget{
  final int index;//决定显示哪个页面
  final String title;
  final Person getperson;// 目标访问用户
  final isOneself;//是否是本人
  final Map<String,dynamic> isVisble;
  final String name;
  RecordDynamicPage({required this.index,required this.title,required this.getperson,required this.isOneself,required this.isVisble,required this.name});
  _RecordDynamicPageState createState()=>_RecordDynamicPageState();

}
class _RecordDynamicPageState extends State<RecordDynamicPage>{
  int Pagenumber = 1; //分页数
  List<Map<String, dynamic>> _posts = []; // 保存获取到的数据作为真正的数据源
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false; // 是否加载
  late Future<List<Map<String,dynamic>>> _postlist;//进来页面第一次拿的数据
  List<Map<String,dynamic>> postlist=[]; // 页面真正使用的数据源
   @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postlist= PostApi.fetchUsedPosts(widget.index,  {
                  'userId': GlobalUser().user!.user_id,
                  'pageNumber': Pagenumber.toString(),            
                });
    // 进行回调
    _postlist.then((result){
        postlist=result;
        return result;

    });
    
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
      Pagenumber=Pagenumber+1;
    });
    Pagenumber += 1;
    List<Map<String, dynamic>> morePosts = await PostApi.fetchUsedPosts(widget.index,  {
      'userId': GlobalUser().user!.user_id,
      'pageNumber': Pagenumber.toString(), 
    }); // 获取更多数据
    if(morePosts.isEmpty){
      setState(() {
        _isLoadingMore = false;
      });
    }else{
    List<Map<String, dynamic>> temp_list=_posts;
      // 遍历新的帖子列表
      for (var newPost in morePosts) {
          // 判断 _posts 列表中是否已经存在相同 postId 的帖子
          bool postExists = _posts.any((post) => post['postId'] == newPost['postId']);
          // 如果帖子不存在，则将其加入 _posts 列表的前面
          if (!postExists) {
            temp_list.add(newPost); // 将新帖子添加到列表的开头
          }
        }
      setState(() {
        _posts = temp_list;
        _isLoadingMore = false;
      });

    }
  }

  // 监听滚动事件，判断是否需要加载更多
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      _loadMorePosts(); // 当滚动到底部时加载更多
    }
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Color(0xFF755DC1),
          fontSize: 25,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    body: Stack(
      children: [
        widget.isVisble[widget.name]
            ? FutureBuilder<List<Map<String, dynamic>>>(
                future: _postlist, 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return NetworkErrorScreen();//网络错误没拿到数据
                  } 
                  else if(!snapshot.hasData || snapshot.data!.isEmpty)
                  {
                    return NoDataScreen(message: 'You dont have any records yet');
                  }
                  else {
                    return  GridView.builder(
                      controller: _scrollController, // 绑定滚动控制器
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 两列
                        crossAxisSpacing: 6.0,
                        mainAxisSpacing: 6.0,
                        childAspectRatio: 0.68, // 长宽比为0.68
                      ),
                      itemCount: postlist.length , // 数据长度 + 加载更多指示器
                      itemBuilder: (context, index) {

                        final post = postlist[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ), // 圆角半径10
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(postId: post['postId'], authorId: post['authorId']),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  child: Image.network(
                                    post['picList'][0]['picUrl'], // 显示第一张图片
                                    fit: BoxFit.cover,
                                    height: 205,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  post['title'].length > 8
                                      ? '${post['title'].substring(0, 8)}...'
                                      : post['title'],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2, top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star_border_outlined, size: 14, color: Colors.yellow),
                                        const SizedBox(width: 4),
                                        Text('${post['collectsNum']}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite, size: 14, color: Colors.red),
                                        const SizedBox(width: 4),
                                        Text('${post['likesNum']}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                              //成功获取数据
                  }
                },
              )
            : const Center(
                child: Text(
                  "This user is not open to you",
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
      ],
    ),
  );
}

}