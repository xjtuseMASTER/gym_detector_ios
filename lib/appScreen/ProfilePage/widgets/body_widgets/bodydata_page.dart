import 'package:flutter/material.dart';

class BodydataPage extends StatefulWidget{
  _BodydataPageState createState()=>_BodydataPageState();


}
class _BodydataPageState extends State<BodydataPage>{
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
        title: const Text('Your Body Data', 
        style: TextStyle(
           color: Color(0xFF755DC1),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
      )
    );
  }

}