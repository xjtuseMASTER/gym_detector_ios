import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BodydataPage extends StatefulWidget {
  @override
  _BodydataPageState createState() => _BodydataPageState();
}

class _BodydataPageState extends State<BodydataPage> {
  int selectedIndex = 0; // 控制当前选中的数据类型
  final List<String> categories = ['Present Height :', 'Present Weight :', 'Present vital capacity :', 'Present BFR :'];
  final List<String> Choices= ['Upload Your Height data', 'upload your Weight data', 'upload your vital capacity', 'upload your BFR'];
  final List<String> categories_description = ['Your Height Trend', 'Your Weight Trend', 'Your vital capacity Trend', 'Your BFR Trend'];
  final List<String> units = ['Cm', 'Kg', 'Cc', '%'];
  
  List<List<double>> exampleData = [
  [173, 173.5, 173, 173], // 身高数据
  [60, 61, 63, 62], // 体重数据
  [3000, 3100, 3050, 3200], // 肺活量数据
  [18, 17.5, 18.2, 18.4], // 体脂率数据
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Your Body Data',
          style: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 30,),
          Container(
              width: 350,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
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
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // 动态曲线图
          SizedBox(height: 10),
         Container(
              margin: const EdgeInsets.all(8.0), // 设置外边距
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 222, 243), // 浅紫色背景
                borderRadius: BorderRadius.circular(20), // 圆角
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 145, 98, 228).withOpacity(0.5), // 阴影颜色
                    spreadRadius: 2, // 阴影扩展
                    blurRadius: 5, // 模糊半径
                    offset: const Offset(0, 3), // 阴影偏移
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0), // 内边距
                child: Column(
                  children: [
                    Container(
                    height: 300, // 调整图表高度
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false), // 移除网格
                        titlesData: FlTitlesData(
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
                          border: Border.all(color:Colors.black, width: 1),
                        ),
                         lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              exampleData[selectedIndex].length,
                              (index) => FlSpot((index + 1).toDouble(), exampleData[selectedIndex][index]),
                            ), // 使用exampleData填充spots
                            isCurved: true,
                            color: Colors.blueAccent,
                            barWidth: 3,
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
          SizedBox(height: 10),
          // 数据卡片布局
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDataCard( Choices[selectedIndex],categories[selectedIndex],exampleData[selectedIndex][exampleData[selectedIndex].length-1].toString(),units[selectedIndex] ),
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
  }

  // 创建小卡片的方法
  Widget _buildDataCard(String title, String description,String value,String units) {
    return GestureDetector(
      onTap: () {
        // 点击卡片后的上传逻辑
        _showUploadDialog(title,units);
      },
      child: Container(
        width: 350,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              description,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 5),
                Text(
              value,
              style: const TextStyle(
                  color: Color.fromARGB(255, 21, 124, 214),
                  fontSize: 13,
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

 void _showUploadDialog(String type,String units) {
  String selectedDate = ''; // 存储选择的日期
  TextEditingController dataController = TextEditingController(); // 存储输入的数据

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
                      fontSize: 16,
                      color: selectedDate.isEmpty ? Colors.blueAccent : Colors.green,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 数据输入框
                TextField(
                  controller: dataController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'input data (${units})',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // 圆角矩形
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedDate.isNotEmpty && dataController.text.isNotEmpty) {
                    //
                  } else {
                    // 提示用户选择日期并输入数据
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please input data first!')),
                    );
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