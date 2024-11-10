import 'package:flutter/material.dart';

class VideoAnalysisPage extends StatelessWidget {
  final List<Map<String, dynamic>> analysisList;

  const VideoAnalysisPage({
    Key? key,
    required this.analysisList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 141, 240)),
        ),
        title: Text(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: analysisList.map((item) {
            return GestureDetector(
            onTap: () {
              
            },
            child:  
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    item['frame'],
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/NetworkError.png');
                              },
                  ),
                  SizedBox(height: 8),
                  Text(
                    item['error'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF755DC1),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item['advice'].substring(0,100),
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            )
            );
          }).toList(),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
    );
  }
}