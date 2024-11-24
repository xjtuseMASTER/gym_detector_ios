import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';


class HealthDashboardView extends StatefulWidget {
  const HealthDashboardView({Key? key}) : super(key: key);

  @override
  State<HealthDashboardView> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboardView> {
  final Health _health = Health(); // Health 插件实例
  List<HealthDataPoint> _healthDataList = [];
  bool _isLoading = true;

  // 获取平台相关的数据类型
  static final types = [
    HealthDataType.WEIGHT,
    HealthDataType.STEPS,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WORKOUT,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    // Uncomment this line on iOS - only available on iOS
    // HealthDataType.AUDIOGRAM
  ];

  List<HealthDataAccess> get permissions => types.map((type) {
        // iOS 平台上部分数据仅支持读取权限
        if ([
          HealthDataType.WALKING_HEART_RATE,
          HealthDataType.ELECTROCARDIOGRAM,
          HealthDataType.HIGH_HEART_RATE_EVENT,
          HealthDataType.LOW_HEART_RATE_EVENT,
        ].contains(type)) {
          return HealthDataAccess.READ;
        }
        return HealthDataAccess.READ_WRITE;
      }).toList();

  @override
  void initState() {
    super.initState();
    _configureHealthPlugin();
    _initializeHealthData();
  }

  void _configureHealthPlugin() {
    // 配置 Health 插件
    _health.configure();
  }

  Future<void> _initializeHealthData() async {
    // 请求权限并获取健康数据
    await authorize();
    await fetchData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> authorize() async {
    // 请求权限
    await Permission.activityRecognition.request();
    await Permission.location.request();

    bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);

    if (hasPermissions == null || !hasPermissions) {
      bool authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (!authorized) {
        debugPrint("授权失败");
        return;
      }
    }

    debugPrint("授权成功");
  }

  Future<void> fetchData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: yesterday,
        endTime: now,
      );

      healthData = _health.removeDuplicates(healthData);

      setState(() {
        _healthDataList = healthData;
      });

      debugPrint("获取到的健康数据：${healthData.length} 条");
    } catch (error) {
      debugPrint("获取数据失败：$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _healthDataList.length,
                itemBuilder: (context, index) {
                  final data = _healthDataList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // 数据类型图标
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.health_and_safety, // 健康数据通用图标
                              size: 32,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 数据展示
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.type.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Value: ${data.value}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Date: ${data.dateFrom.toLocal()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}