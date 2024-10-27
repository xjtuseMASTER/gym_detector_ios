```dart
Future<void> _handleFeedbackSubmission() async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Submitting...');

    // 发送请求
    final response = await customHttpClient.get(
        Uri.parse('http://127.0.0.1:4523/m2/5245288-4913049-default/222467509').replace(
          queryParameters: {
            'user_emial': user_email, // 传入 user_id 参数
            'password':_passController.text //密码
          },
        ),
      );

    if (response.statusCode == 200) {
      // 请求成功
      //  提取 data 部分
      final jsonResponse=json.decode(response.body);
      final data = jsonResponse['data'];
      saveUserData(Person.fromJson(data));
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Login Successfully');
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
}



//发布帖子上传数据
Future<void> _handleRelease(BuildContext context) async {
  LoadingDialog.show(context, 'Releasing...'); // 显示加载指示器

  try {

    // 发送 POST 请求到后端
    final response = await customHttpClient.post(
      Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/post/release'),
      body: jsonEncode(postSummary),
    );

    if (response.statusCode == 200) {
      // 处理返回的数据
      final jsonResponse = json.decode(response.body);
      post_id = jsonResponse['data']['post_id'];
      print('数据获取成功');
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Release Successfully！');
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
```
```dart
//未来widget体构建

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          'Your Body Data',
          style: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<bool>(
        future: fetchBodyDataSequentially(),  // 异步顺序加载数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}')); // 错误处理
          } else if (snapshot.hasData && snapshot.data == true) {
            return  Scaffold(
       
    );
          } else {
            return Center(child: Text('Failed to load data')); // 如果数据加载失败，显示错误提示
          }
        },
      ),
    );
  }


//简单的获取数据，配合futurebuilder使用
// 异步获取数据
  Future<bool> fetchCommentData() async {
    try {
      // 获取数据
      final Response = await customHttpClient.get(Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/post/detail').replace(
         queryParameters: {
            'post_id': widget.post_id
          }
      ));
      if (Response.statusCode == 200) {
         final jsonResponse = json.decode(Response.body);
         commentlist= jsonResponse['data']['commentList'];
        isExpandedList = List.generate(commentlist.length, (index) => false);
      } else {
        throw Exception('Failed to fetch Comment data');
      }
      return true; // 数据加载成功
    } catch (e) {
      return false;
    }
  }

```




```dart
@override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          );
    return Scaffold(
      body: FutureBuilder<bool>(
        future: fetchPostData(),  // 异步顺序加载数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}')); // 错误处理
          } else if (snapshot.hasData && snapshot.data == true) {
            return

          }else {
            return Center(child: Text('Failed to load data')); // 如果数据加载失败，显示错误提示
          }
        }
      )
    );

  }
```