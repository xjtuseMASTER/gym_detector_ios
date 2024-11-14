import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/appScreen/ProfilePage/record_dynamic_page.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/global_module/global_user_preferences.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/widgets/http.dart';

class DynamiclistView extends StatefulWidget {
  final Person getperson; // 目标访问用户
  final bool isOneself; // 是否是本人

  DynamiclistView({required this.getperson, required this.isOneself});

  @override
  _DynamiclistViewState createState() => _DynamiclistViewState();
}

class _DynamiclistViewState extends State<DynamiclistView> {
  final List<String> dynamicBarNames = ['Likes', 'Release', 'Collects'];
  final List<String> dynamicBarImages = [
    'assets/bar_images/tbar1.png',
    'assets/bar_images/tbar2.png',
    'assets/bar_images/tabr3.png',
  ];
  final List<String> dynamicBarDescriptions = [
    'Used To Like',
    'Used To Release',
    'Used To Collect',
  ];
  final List<bool> foodHighlights = [true, true, true]; // 示例
  Map<String, dynamic> _isVisible = {
    "isLikesVisible": true,
    "isReleaseVisible": true,
    "isCollectsVisible": true,
  };

  @override
  void initState() {
    super.initState();
    fetchUserPreferencesFromBackend(widget.getperson.user_id);
  }

  Future<void> fetchUserPreferencesFromBackend(String user_id) async {
  try {
    final response = await customHttpClient.get(
      Uri.parse('${Http.httphead}/user_preference/getpreferences')
          .replace(queryParameters: {
        'user_id': user_id, // 传入 user_email 参数
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      // 仅在 Widget 仍然挂载时调用 setState
      if (mounted) {
        setState(() {
          _isVisible = {
            "isLikesVisible": widget.isOneself
                ? true
                : data['isLikesVisible'] == 1,
            "isReleaseVisible": widget.isOneself
                ? true
                : data['isReleaseVisible'] == 1,
            "isCollectsVisible": widget.isOneself
                ? true
                : data['isCollectsVisible'] == 1,
          };
        });
      }
    } else {
      throw Exception('Failed to load user preferences');
    }
  } catch (e) {
    // 错误处理
    print("Error: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            String name = '';
            if (index == 0) {
              name = 'isLikesVisible';
            } else if (index == 1) {
              name = 'isReleaseVisible';
            } else {
              name = 'isCollectsVisible';
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordDynamicPage(
                  index: index,
                  title: dynamicBarDescriptions[index],
                  getperson: widget.getperson,
                  isOneself: widget.isOneself,
                  isVisble: _isVisible,
                  name: name,
                ),
              ),
            );
          },
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  const Color.fromARGB(255, 205, 139, 217).withOpacity(0.4),
                  const Color.fromARGB(255, 183, 209, 230).withOpacity(0.4),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(dynamicBarImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, left: 15, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dynamicBarNames[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 15,
                            )
                          ],
                        ),
                        Text(
                          dynamicBarDescriptions[index],
                          style: TextStyle(
                            color: foodHighlights[index]
                                ? const Color.fromARGB(255, 198, 127, 229)
                                : Colors.grey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (_, index) => const SizedBox(
          height: 15,
        ),
        itemCount: dynamicBarNames.length,
      ),
    );
  }
}