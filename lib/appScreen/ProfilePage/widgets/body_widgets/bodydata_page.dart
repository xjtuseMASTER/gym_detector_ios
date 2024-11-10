import 'dart:convert';
import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:gym_detector_ios/widgets/loading_dialog.dart';
import 'package:http/http.dart' as http;

class BodydataPage extends StatefulWidget {
  @override
  _BodydataPageState createState() => _BodydataPageState();
}

class _BodydataPageState extends State<BodydataPage>  with AutomaticKeepAliveClientMixin{
  int selectedIndex = 0; // 控制当前选中的数据类型
  final List<String> categories = ['Present Height :', 'Present Weight :', 'Present vital capacity :', 'Present BFR :'];
  final List<String> Choices= ['Upload Your Height data', 'upload your Weight data', 'upload your vital capacity', 'upload your BFR'];
  final List<String> categories_description = ['Your Height Trend', 'Your Weight Trend', 'Your vital capacity Trend', 'Your BFR Trend'];
  final List<String> units = ['Cm', 'Kg', 'Cc', '%'];
  late List<int> heightList;//身高数据
  late List<int> weightList;//体重数据
  late List<int> bodyFatRateList;//体脂率数据
  late List<int> vitalCapacityList;//肺活量数据
  List<List<int>>  bodyData=[];
   @override
  bool get wantKeepAlive => true; // 确保页面状态保持

   
  // 异步依次获取四个接口的数据
  Future<bool> fetchBodyDataSequentially() async {
    try {
      // 获取身高数据
      final heightResponse = await customHttpClient.get(
        Uri.parse('${Http.httphead}/user_height/getheightlist').replace(
          queryParameters: {
            'userId':GlobalUser().user!.user_id
          }
        )
      );
      if (heightResponse.statusCode == 200) {
        heightList = _parseData(heightResponse.body, 'heightList');
        bodyData.add(heightList);
      } else {
        bodyData.add([0,0,0,0,0]);
        CustomSnackBar.showSuccess(context, "You haven't uploaded any data！");
        throw Exception('Failed to fetch height data');
      }

      // 获取体重数据
      final weightResponse = await customHttpClient.get(Uri.parse('${Http.httphead}/user_weight/getweightlist').replace(
          queryParameters: {
            'user_id':GlobalUser().user!.user_id
          }
      )
      );
      if (weightResponse.statusCode == 200) {
        weightList = _parseData(weightResponse.body, 'weightList');
        bodyData.add(weightList);
      } else {
         bodyData.add([0,0,0,0,0]);
         CustomSnackBar.showSuccess(context, "You haven't uploaded any data！");
        throw Exception('Failed to fetch weight data');
      }

      // 获取肺活量数据
      final vitalCapacityResponse = await customHttpClient.get(Uri.parse('${Http.httphead}/user_vital_capacity/getvitalcapacitylist').replace(
          queryParameters: {
            'user_id':GlobalUser().user!.user_id
          }
      ));
      if (vitalCapacityResponse.statusCode == 200) {
        vitalCapacityList = _parseData(vitalCapacityResponse.body, 'vitalCapacityList');
        bodyData.add(vitalCapacityList);
      } else {
         bodyData.add([0,0,0,0,0]);
         CustomSnackBar.showSuccess(context, "You haven't uploaded any data！");
        throw Exception('Failed to fetch vital capacity data');
      }

      // 获取体脂率数据
      final bodyFatResponse = await customHttpClient.get(Uri.parse('${Http.httphead}/user_body_fat_rate/getbodyfatlist').replace(
          queryParameters: {
            'user_id':GlobalUser().user!.user_id
          }
      ));
      if (bodyFatResponse.statusCode == 200) {
        bodyFatRateList = _parseData(bodyFatResponse.body, 'bodyFatRateList');
        bodyData.add(bodyFatRateList);
      } else {
         bodyData.add([0,0,0,0,0]);
         CustomSnackBar.showSuccess(context, "You haven't uploaded any data！");
        throw Exception('Failed to fetch body fat rate data');
      }

      return true; // 数据加载成功
    } catch (e) {
      return false;
    }
  }


  //上传身体数据
  Future<void> _handleSubmit(String date,String data,int selectedIndex) async {
  try {
    // 显示加载对话框
    LoadingDialog.show(context, 'Submitting...');
    http.Response response;
    switch(selectedIndex){
      //上传身高
      case 0:  response= await customHttpClient.get(
        Uri.parse('${Http.httphead}/user_height/uploadheight').replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
            'height':data,
            'date':date
          },
        ),
      );
      break;
       //上传体重
      case 1: response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/user_weight/uploadweight').replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
            'weight':data,
            'date':date
          },
        ),
      );
      break;
       //上传肺活量
      case 2: response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/user_vital_capacity/uploadvitalcapacity').replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
            'vital_capacity':data,
            'date':date
          },
        ),
      );
      break;
       //上传体脂率
      case 3:  response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/user_body_fat_rate/uploadbodyfatrate').replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id, // 传入 user_id 参数
            'body_fat_rate':data,
            'date':date
          },
        ),
      );
      break;

    default:
      throw Exception('Invalid selectedIndex');
    }

    if (response.statusCode == 200) {
      // 请求成功
      //  提取 data 部分
      LoadingDialog.hide(context);
      CustomSnackBar.showSuccess(context, 'Submit Successfully');
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

  // 解析数据
  List<int> _parseData(String responseBody, String key) {
    final jsonResponse = json.decode(responseBody);
    final data = jsonResponse['data'][key];
    return List<int>.from(data); // 将数据转换为List<double>
  }

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
          body: Column(
        children: [
          SizedBox(height: 30.h,),
          Container(
              width: 350.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    categories_description[selectedIndex],
                    style: TextStyle(
                      color: Color(0xFF755DC1),
                      fontSize: 20.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // 动态曲线图
          SizedBox(height: 10.h),
         Container(
              margin:  EdgeInsets.all(8.0.w), // 设置外边距
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 222, 243), // 浅紫色背景
                borderRadius: BorderRadius.circular(20.r), // 圆角
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 145, 98, 228).withOpacity(0.5), // 阴影颜色
                    spreadRadius: 2.r, // 阴影扩展
                    blurRadius: 5.r, // 模糊半径
                    offset: const Offset(0, 3), // 阴影偏移
                  ),
                ],
              ),
             child: Padding(
          padding: EdgeInsets.all(12.0.w), // 内边距
          child: Column(
            children: [
              Container(
                height: 300.h, // 调整图表高度
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false), // 移除网格
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // 隐藏顶部标题
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // 隐藏右侧标题
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    // 动态设置纵轴最小值和最大值
                    // 动态设置纵轴最小值和最大值
                      minY: bodyData[selectedIndex].every((value) => value == 0) ? 0 : bodyData[selectedIndex].reduce((a, b) => a < b ? a : b).toDouble(),
                      maxY: bodyData[selectedIndex].every((value) => value == 0) ? 1 : bodyData[selectedIndex].reduce((a, b) => a > b ? a : b).toDouble(),
                        lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          bodyData[selectedIndex].length,
                          (index) => FlSpot(
                            (index + 1).toDouble(),
                            bodyData[selectedIndex][index].toDouble(),
                          ),
                        ), // 使用bodyData填充spots
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3.w,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
          SizedBox(height: 10.h),
          // 数据卡片布局
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 20.0.h, horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 _buildDataCard(
                    Choices[selectedIndex],
                    categories[selectedIndex],
                    bodyData[selectedIndex].isNotEmpty
                        ? bodyData[selectedIndex].last.toString() // 获取最后一个值
                        : '0',
                    units[selectedIndex],
                    selectedIndex,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Color(0xFF755DC1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.height),
            label: 'Height',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Weight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.air),
            label: 'Vital Capacity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: 'BFR',
          ),
        ],
      ),
    );
          } else {
            return Center(child: Text('Failed to load data')); // 如果数据加载失败，显示错误提示
          }
        },
      ),
    );
  }


  // 创建小卡片的方法
  Widget _buildDataCard(String title, String description,String value,String units,int selectindex) {
    return GestureDetector(
      onTap: () {
        // 点击卡片后的上传逻辑
        _showUploadDialog(title,units,selectindex);
      },
      child: Container(
        width: 350.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style:  TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 17.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              description,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 5.w),
                Text(
              value,
              style: TextStyle(
                  color: Color.fromARGB(255, 21, 124, 214),
                  fontSize: 13.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showUploadDialog(String type,String units ,int selectindex ) {
    String selectedDate = ''; // 存储选择的日期
    TextEditingController dataController = TextEditingController(); // 存储输入的数据
    bool isSubmit=true;//判断输入是否有效
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 圆角设计
              ),
              title: Text(type),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 日期选择按钮
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        });
                      }
                    },
                    child: Text(
                      selectedDate.isEmpty ? 'chose date' : 'Chosed: $selectedDate',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: selectedDate.isEmpty ? Colors.blueAccent : Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // 数据输入框
                  TextField(
                    controller: dataController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'input data (${units})',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r), // 圆角矩形
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                    SizedBox(height: 5.h),
                  Offstage(
                    offstage: isSubmit,  
                    child: Text(
                      'Please input valid data！',
                      style: TextStyle(
                        color: Color.fromARGB(255, 212, 19, 19),
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                 onPressed: (){

                 },
                  child: Text('Cancel'),
                ),
                TextButton(
                   onPressed: () async {
                    // 获取输入的数据
                    String inputData = dataController.text;
                    if (selectedDate != '' && inputData.isNotEmpty) {
                      // 根据 selectedIndex 判断输入数据的合理性
                      bool isValid=true;
                      switch (selectedIndex) {
                        case 0:  // 身高 (合理范围示例: 50cm - 250cm)
                          double? height = double.tryParse(inputData);
                          if (height == null || height < 50 || height > 250) {
                            isValid = false;
                          }
                          break;
                        case 1:  // 体重 (合理范围示例: 10kg - 500kg)
                          double? weight = double.tryParse(inputData);
                          if (weight == null || weight < 10 || weight > 500) {
                            isValid = false;
                          }
                          break;
                        case 2:  // 肺活量 (合理范围示例: 500ml - 10000ml)
                          double? vitalCapacity = double.tryParse(inputData);
                          if (vitalCapacity == null || vitalCapacity < 500 || vitalCapacity > 10000) {
                            isValid = false;
                          }
                          break;
                        case 3:  // 体脂率 (合理范围示例: 1% - 100%)
                          double? bodyFatRate = double.tryParse(inputData);
                          if (bodyFatRate == null || bodyFatRate < 1 || bodyFatRate > 100) {
                            isValid = false;
                          }
                          break;
                        default:
                          isValid = false;
                          break;
                      }

                      // 如果输入数据有效，提交数据；否则，显示错误提示
                      if (isValid) {
                        // 提交身体数据
                        await _handleSubmit(selectedDate, inputData, selectedIndex);
                        Navigator.pop(context);  // 关闭弹窗
                        setState((){
                           bodyData[selectindex].add(int.parse(inputData));//暂时整数，后续再改
                        });
                      } else {
                        setState(() {
                          isSubmit = false;
                          dataController.text='';
                          
                        });
                      }
                    } else {
                      // 信息没有填写完整
                      CustomSnackBar.showFailure(context, 'Please input first!');
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
}