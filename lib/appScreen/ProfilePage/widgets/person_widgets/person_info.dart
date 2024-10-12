import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/module/person.dart';

class PersonInfo extends StatefulWidget {
  final Person person;
  PersonInfo({required this.person});

  @override
  _PersonInfoState createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
  bool isEditing = false; // 是否处于编辑模式
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _birthdateController;
  late TextEditingController _signatureController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _genderController = TextEditingController(text: widget.person.sex);
    _birthdateController = TextEditingController(text: widget.person.birthdate);
    _signatureController = TextEditingController(text: widget.person.sign_name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEditing//根据一个逻辑变量来控制信息是显示状态还是编辑状态
              ? TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name"),
                )
              : Text(
                  widget.person.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
          SizedBox(height: 15),

          // 信息卡片显示
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // 圆角
            ),
            elevation: 4, // 阴影
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Account", widget.person.ID),
                  SizedBox(height: 16),
                  _buildInfoRow("Email", widget.person.email),
                  SizedBox(height: 16),
                  isEditing
                      ? TextField(
                          controller: _genderController,
                          decoration: InputDecoration(labelText: "Gender"),
                        )
                      : _buildInfoRow("Gender", widget.person.sex),
                  SizedBox(height: 16),
                  isEditing
                      ? TextField(
                          controller: _birthdateController,
                          decoration: InputDecoration(labelText: "Birthdate"),
                        )
                      : _buildInfoRow("Birthdate", widget.person.birthdate),
                  SizedBox(height: 16),
                  isEditing
                      ? TextField(
                          controller: _signatureController,
                          decoration: InputDecoration(labelText: "Signature"),
                        )
                      : _buildInfoRow("Signature", widget.person.sign_name),
                ],
              ),
            ),
          ),

          // 编辑按钮
          SizedBox(height: 30),
          Center(
        child: ElevatedButton(
          onPressed: () {
            if (isEditing) {
              // 提交修改
              _submitChanges();
            }
            setState(() {
              isEditing = !isEditing;
            });
          },
          child: Text(isEditing ? "Save" : "Edit Personal Info"),
        ),
      ),
        ],
      ),
    );
  }

  // 用于显示信息的行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 提交修改到后端的方法
  void _submitChanges() {
    // 假设你有一个接口方法 submitPersonInfo() 用来提交修改的数据到后端
    Map<String, String> updatedInfo = {
      "name": _nameController.text,
      "gender": _genderController.text,
      "birthdate": _birthdateController.text,
      "signature": _signatureController.text,
    };

    // 在此调用你的后端接口
    submitPersonInfo(updatedInfo);
  }

  // 模拟的后端接口提交方法
  void submitPersonInfo(Map<String, String> updatedInfo) {
    // 这里是你将修改后的信息发送到后端的逻辑
    print("Submitted info: $updatedInfo");
  }
}