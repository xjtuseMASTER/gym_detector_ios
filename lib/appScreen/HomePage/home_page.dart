
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/HomePage/create_post_page.dart';
import 'package:gym_detector_ios/appScreen/HomePage/feedback_page.dart';
import 'package:gym_detector_ios/appScreen/HomePage/postdetail_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/profile_page.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/widgets/preference_widgets/account_security_page.dart';
import 'package:gym_detector_ios/module/cache_module/cache_utils/first_post_repository.dart';
import 'package:gym_detector_ios/module/cache_module/first_post.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/services/api/Post/post_api.dart';

class HomePage extends StatefulWidget {
  List<Map<String, dynamic>> initialPosts;
 _HomePageState createState()=>_HomePageState();
 HomePage({required this.initialPosts});
}
class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  final Person user =GlobalUser().getUser()!;
  int PageNumber=1;//页码
  List<Map<String, dynamic>> _posts = []; // 保存获取到的数据作为真正的数据源
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;//是否加载
  bool _isRefreshing = false;//是否刷新
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _posts=widget.initialPosts;
    _scrollController.addListener(_onScroll);
  }
   @override
  bool get wantKeepAlive => true; // 确保页面状态保持

   //跳转回调
    void _navigateToRelease(BuildContext context) async {
    final NewPost = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(),
      ),
    );
    // 检查返回的值并更新状态
    if (NewPost != null) {
      setState(() {
        _posts.insert(0, NewPost);//将新发的帖子放在第一条
      });
    }
  }
   // 下拉刷新功能
  Future<void> _refreshPosts(BuildContext context) async {
    setState(() {
      _isRefreshing = true;
    });
    final queryParameters= {
          'user_id': GlobalUser().user!.user_id,
          'pageNumber': '1', // 确保 pageNumber 为字符串
        };
    List<Map<String, dynamic>> newPosts = await PostApi.fetchNewPosts(context,queryParameters); // 获取更多的数据
      if(newPosts.isEmpty){
        _posts=_posts;//不刷新
        setState(() {
           _isRefreshing = false;
        });
      }
      else{
       List<Map<String, dynamic>> temp_list=_posts;
       //做一遍去重遍历
       for(var newPost in newPosts){
        bool postExits=_posts.any((post)=>post['postId']==newPost['postId']);
        if(!postExits)
        {
          temp_list.insert(0, newPost);
        }
       }
       // 更新本地缓存
      await FirstPostRepository.addFirstPost(FirstPost(data: newPosts));
       setState(() {
         _posts = temp_list;
          _isRefreshing = false;
        
      });
      }
    
  }

  // 上拉加载更多功能
  Future<void> _loadMorePosts(BuildContext context) async {
    
    if (_isLoadingMore) return; // 防止重复请求
    setState(() {
      _isLoadingMore = true;
    });
    PageNumber++;
    final queryParameters= {
          'user_id': GlobalUser().user!.user_id,
          'pageNumber': PageNumber.toString(), // 确保 pageNumber 为字符串
        };
    List<Map<String, dynamic>> morePosts = await PostApi.fetchNewPosts(context,queryParameters); // 获取更多的数据
    //如果没有更多的帖子
    if(morePosts.isEmpty){
      setState(() {
        _isLoadingMore = false;
        _posts=_posts;
      });
    }else{
    //如果有更多的帖子
    List<Map<String, dynamic>> temp_list=_posts;
      // 遍历新的帖子列表
      for (var newPost in morePosts) {
          // 判断 _posts 列表中是否已经存在相同 postId 的帖子
          bool postExists = _posts.any((post) => post['postId'] == newPost['postId']);
          
          // 如果帖子不存在，则将其加入 _posts 列表的前面
          if (!postExists) {
            temp_list.add(newPost); // 将新帖子添加到列表的后面
          }
        }
      setState(() {
        _posts = temp_list;
        _isLoadingMore = false;
      });

    }
      
  }
  // 监听滚动事件，判断是否需要加载更多
  void _onScroll()async {
    if ((_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 50) && !_isLoadingMore) {
      await _loadMorePosts(context);
    }
  }  

   @override
  Widget build(BuildContext context) {
    print(widget.initialPosts.length);
    super.build(context); 
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.avatar)
              ),
              onPressed: () {
                // 点击头像，打开侧边栏
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Show Yourself!',
          style: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.headset_mic, color: Color(0xFF755DC1)),
            onPressed: () {
              // 点击反馈按钮
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> FeedbackPage())
               );
            },
          ),
        ],
      ),
      drawer: Container(
      width: 200,
      child: Drawer(
         child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(user.avatar), // 替换为用户头像
                    fit: BoxFit.cover, // 使图片填充整个区域
                  ),
                  color: Colors.white, // 叠加的白色背景
              ),
              child: const Text(
                ''
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person,color: Colors.grey),
              title: const Text(
                'Personal Homepage',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(selected: 0)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings,color: Colors.grey),
              title: const Text(
                'Settings',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(selected: 2)));
              },
            ),
             ListTile(
              leading: const Icon(Icons.logout,color: Colors.grey),
              title: const Text(
                'Account',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AccountSecurityPage()));
              },
            ),
             ListTile(
              leading: const Icon(Icons.scanner_rounded,color: Colors.grey),
              title: const Text(
                'Scanner',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {},
            ),
             ListTile(
              leading: const Icon(Icons.dynamic_feed,color: Colors.grey),
              title: const Text(
                'Personal dynamics',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.question_mark_outlined,color: Colors.grey),
              title: const Text(
                'About us',
                style: TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
              ),
              onTap: () {},
            ),
          ]
        )
       ),
      ),
      body: 
      Stack(
      children: [  
      widget.initialPosts.isEmpty
          ? Center(child: CircularProgressIndicator())
          // : SquarePostView(initialPosts: widget.initialPosts, person: user,fetchMorePosts: fetchMorePosts,fetchNewPosts: fetchNewPosts,),//瀑布流展示widget
          :RefreshIndicator(
              onRefresh: () async {
                await _refreshPosts(context);
                  }, // 下拉刷新
              child: GridView.builder(
                controller: _scrollController, // 绑定滚动控制器
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 一共两列
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 6.0,
                  childAspectRatio: 0.68, // 长宽比为0.68
                ),
                itemCount: _posts.length + (_isLoadingMore ? 1 : 0), // 数据长度 + 加载更多指示器
                itemBuilder: (context, index) {
                  if (index == _posts.length && _isLoadingMore) {
                    // 显示加载指示器
                    return Center();
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
                                builder: (context) => DetailPage(
                                    postId: post['postId'], authorId: post['autherId']),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            child: post['picList'] == null || post['picList'].isEmpty ?
                              Image.asset(
                                'assets/images/NetworkError.png',
                                height: 205,
                                width: double.infinity,
                              ) :
                              CachedNetworkImage(
                            imageUrl: post['picList'][0]['picUrl'],
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
                          )
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            post['title'].length > 8
                                ? '${post['title'].substring(0, 8)}...'
                                : post['title'],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rate_outlined,
                                      size: 14, color: Colors.yellow),
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
              ),
            ),
            Positioned( //右下角放置用户发布动态按钮
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor:  Color.fromARGB(255, 142, 127, 192),
                onPressed: (){
                  _navigateToRelease(context);//跳转到发布动态页面
                },
                child: Icon(Icons.add),                
              )

            )
      ]
      )
    );
  }
}