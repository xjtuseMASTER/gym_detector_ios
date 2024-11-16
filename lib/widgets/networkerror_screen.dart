import 'package:flutter/material.dart';

class NetworkErrorScreen extends StatelessWidget {
  final String errorMessage;

  const NetworkErrorScreen({Key? key, this.errorMessage = "Network Error, Failed to load post data!"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding for the text
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center both horizontally and vertically
            children: [
              Icon(
                Icons.sentiment_very_dissatisfied,
                color: Color(0xFF755DC1),
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                "     Network Error, Failed to load post data!",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}