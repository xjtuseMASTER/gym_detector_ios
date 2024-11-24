// 历史上传数据
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/AppPage/VideoAnalysis_page.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/services/utils/decode_response_data.dart';
import 'package:gym_detector_ios/services/utils/handle_http_error.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';
import 'package:nim_core/nim_core.dart';

class HistoryUploadPage extends StatefulWidget {
  @override
  _HistoryUploadPageState createState() => _HistoryUploadPageState();
}

class _HistoryUploadPageState extends State<HistoryUploadPage> {
  late Future<List<Map<String, dynamic>>> _historyDataFuture;

  @override
  void initState() {
    super.initState();
    _historyDataFuture = _fetchHistoryData();
  }

  Future<List<Map<String, dynamic>>> _fetchHistoryData() async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/history/history').replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id,
          },
        ),
      );

      if (response.statusCode == 200) {
        // 请求成功
        final List<dynamic> postList =
            DecodeResponseData.transfer_to_Map(response);
        return postList.map((post) => post as Map<String, dynamic>).toList();
      } else {
        HandleHttpError.handleErrorResponse(context, response.statusCode);
        return [];
      }
    } catch (e) {
      // 捕获网络异常
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchHistoryDetail(
      String history_video_id) async {
    try {
      // 发送请求
      final response = await customHttpClient.get(
        Uri.parse('${Http.httphead}/history/onehistory').replace(
          queryParameters: {
            'user_id': GlobalUser().user!.user_id,
            'history_video_id': history_video_id
          },
        ),
      );

      if (response.statusCode == 200) {
        // 请求成功
        final decodedBody = utf8.decode(response.bodyBytes); 
        final jsonResponse = json.decode(decodedBody);

          // 确保将 'analysis' 解析为 List 类型
           String analysisString = jsonResponse['data']['analysis'];
          analysisString = analysisString.replaceAll("'", "\"");

          // 如果 analysis 是类似 JSON 格式的字符串，解析它
          final List<Map<String, dynamic>> analysisList = List<Map<String, dynamic>>.from(
              json.decode(analysisString)
          );

        return analysisList;
      } else {
        HandleHttpError.handleErrorResponse(context, response.statusCode);
        return [];
      }
    } catch (e) {
      // 捕获网络异常
      CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
      return [];
    }
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () async {
            List<Map<String, dynamic>> analysisList =
                await _fetchHistoryDetail(item["history_video_id"]);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>VideoAnalysisPage(analysisList: analysisList,ishistory: true,) ));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                // 图片
                Image.network(
                  item['video_url'].replaceFirst(RegExp(r'\.mov$'), '.jpg'),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image,
                          size: 50, color: Colors.grey),
                    );
                  },
                ),
                // 时间
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      item['time'].substring(0, 16),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 212, 141, 240)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'History Uploads',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load data'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No history uploads found'),
            );
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return _buildHistoryCard(item);
            },
          );
        },
      ),
    );
  }
}

