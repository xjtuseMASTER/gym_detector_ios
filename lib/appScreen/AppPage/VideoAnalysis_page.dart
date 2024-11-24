import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class VideoAnalysisPage extends StatefulWidget {
  final List<Map<String, dynamic>> analysisList;
  final bool ishistory;

  const VideoAnalysisPage({
    Key? key,
    required this.analysisList,
    required this.ishistory,
  }) : super(key: key);

  @override
  _VideoAnalysisPageState createState() => _VideoAnalysisPageState();
}

class _VideoAnalysisPageState extends State<VideoAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 141, 240)),
        ),
        title: const Text(
          'Analysis Result',
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
      body: 
      widget.analysisList.length==0?
      Center(child: Text('You do the best!',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)):
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.analysisList.length,
        itemBuilder: (context, index) {
          final item = widget.analysisList[index];
          return VideoAnalysisCard(
            picUrl: item['frame'],
            error: item['error'],
            advice: item['advice'],
            ishistory: widget.ishistory,
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}

class VideoAnalysisCard extends StatefulWidget {
  final String picUrl;
  final String error;
  final String advice;
  final bool ishistory;

  const VideoAnalysisCard({
    Key? key,
    required this.picUrl,
    required this.error,
    required this.advice,
    required this.ishistory,
  }) : super(key: key);

  @override
  _VideoAnalysisCardState createState() => _VideoAnalysisCardState();
}

class _VideoAnalysisCardState extends State<VideoAnalysisCard> {
  String displayedText = ""; // 当前显示的文本
  int charIndex = 0; // 当前显示的字符索引
  bool isTextGenerated = false; // 标记文本是否已经生成

  @override
  void initState() {
    super.initState();
    if (!isTextGenerated) {
      _startStreaming(widget.advice); // 开始逐字显示 advice
      isTextGenerated = true; // 标记文本已经生成
    }
  }

  void _startStreaming(String fullText) async {
    while (charIndex < fullText.length) {
      await Future.delayed(const Duration(milliseconds: 10)); // 每50ms显示一个字符
      if (mounted) {
        setState(() {
          displayedText += fullText[charIndex]; // 逐字符添加
          charIndex++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.picUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/NetworkError.png');
            },
          ),
          const SizedBox(height: 8),
          Text(
            widget.error,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF755DC1),
            ),
          ),
          const SizedBox(height: 8),
          widget.ishistory?
           MarkdownBody(
                    data: widget.advice,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ):
          MarkdownBody(
            data: displayedText, // 渲染流式文本
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}