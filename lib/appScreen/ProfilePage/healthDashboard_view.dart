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
  final Health _health = Health();
  List<HealthDataPoint> _healthDataList = [];
  bool _isLoading = true;
  bool _hasPermissions = false;
  String? _error;

  // 只获取基础且通用的数据类型
  static final List<HealthDataType> types = Platform.isIOS 
    ? [
        HealthDataType.STEPS,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
      ]
    : [
        HealthDataType.STEPS,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHealth();
    });
  }

  // 初始化健康数据
  Future<void> _initializeHealth() async {
    try {
      // 配置health插件
      bool isConfigured = await _health.hasPermissions(types) ?? false;
      if (!isConfigured) {
        _hasPermissions = await _requestHealthPermissions();
      } else {
        _hasPermissions = true;
      }

      if (_hasPermissions) {
        await _fetchHealthData();
      } else {
        setState(() {
          _error = "未获得健康数据访问权限";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "初始化失败: $e";
        _isLoading = false;
      });
    }
  }

  // 请求健康数据权限
  Future<bool> _requestHealthPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (status.isDenied) return false;
      }
      
      return await _health.requestAuthorization(types);
    } catch (e) {
      debugPrint("请求权限失败: $e");
      return false;
    }
  }

  // 获取健康数据
  Future<void> _fetchHealthData() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 7)); // 获取一周的数据

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: yesterday,
        endTime: now,
      );

      if (mounted) {
        setState(() {
          _healthDataList = _health.removeDuplicates(healthData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "获取数据失败: $e";
          _isLoading = false;
        });
      }
    }
  }

  // 将健康数据点转换为可读文本
  String _getReadableValue(HealthDataPoint point) {
    if (point.type == HealthDataType.STEPS) {
      return "${point.value} 步";
    } else if (point.type == HealthDataType.WEIGHT) {
      return "${point.value} kg";
    } else if (point.type == HealthDataType.HEIGHT) {
      return "${point.value} cm";
    }
    return point.value.toString();
  }

  // 获取数据类型对应的图标
  IconData _getIconForType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return Icons.directions_walk;
      case HealthDataType.WEIGHT:
        return Icons.monitor_weight;
      case HealthDataType.HEIGHT:
        return Icons.height;
      default:
        return Icons.health_and_safety;
    }
  }

  // 获取数据类型的显示名称
  String _getTypeDisplayName(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return "步数";
      case HealthDataType.WEIGHT:
        return "体重";
      case HealthDataType.HEIGHT:
        return "身高";
      default:
        return type.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康数据'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _hasPermissions ? () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _fetchHealthData();
            } : null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_healthDataList.isEmpty) {
      return const Center(
        child: Text(
          '暂无健康数据',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHealthData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _healthDataList.length,
        itemBuilder: (context, index) {
          final data = _healthDataList[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(
                  _getIconForType(data.type),
                  color: Colors.blue,
                ),
              ),
              title: Text(
                _getTypeDisplayName(data.type),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '时间: ${data.dateFrom.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                _getReadableValue(data),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}