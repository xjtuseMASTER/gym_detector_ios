
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/services/api/User/changeuser_api.dart';


class PersonInfo extends StatefulWidget {
  final Person person;
  PersonInfo({required this.person});

  @override
  _PersonInfoState createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
  // ignore: non_constant_identifier_names
  late String userName;
  late String gender;
  late String selfInfo;
  late String selectedDate; // 存储选择的日期
  bool isEditing = false; // 是否处于编辑模式
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _signatureController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.user_name);
    _genderController = TextEditingController(text: widget.person.gender);
    _signatureController = TextEditingController(text: widget.person.selfInfo);
    selectedDate = widget.person.birthday; // 存储选择的日期
    userName=widget.person.user_name;
    gender=widget.person.gender;
    selfInfo=widget.person.selfInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.w),
      color: Colors.white,
      child: SingleChildScrollView(  // 新增 SingleChildScrollView
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEditing//根据一个逻辑变量来控制信息是显示状态还是编辑状态
              ? TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name"),
                  maxLength: 15,
                )
              : Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
          const SizedBox(height: 15),
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
                  _buildInfoRow("Account", widget.person.user_id),
                  SizedBox(height: 16.h),
                  _buildInfoRow("Email", widget.person.email),
                  SizedBox(height: 16.h),
                  isEditing
                      ? TextField(
                          controller: _genderController,
                          decoration: InputDecoration(labelText: "Gender"),
                        )
                      : _buildInfoRow("Gender", gender),
                  SizedBox(height: 16.h),
                  isEditing
                      ? // 日期选择按钮
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
                      )
                      : _buildInfoRow("Birthday", selectedDate),
                  SizedBox(height: 16.h),
                  isEditing
                      ? TextField(
                          controller: _signatureController,
                          decoration: InputDecoration(labelText: "Signature"),
                          maxLength: 30,
                        )
                      : _buildInfoRow("Signature", selfInfo),
                ],
              ),
            ),
          ),
          // 编辑按钮
          SizedBox(height: 30.h),
          Center(
        child: ElevatedButton(
          onPressed: () async{
            if (isEditing) {
              // 提交修改
              await _submitChanges(context);
              setState(() {
                userName=_nameController.text;
                gender=_genderController.text;
                selfInfo=_signatureController.text;
              });
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
      )
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
  Future<void> _submitChanges(BuildContext context)async {
    Map<String, String> updatedInfo = {
      "user_id":GlobalUser().user!.user_id,
      "user_name": _nameController.text,
      "gender": _genderController.text,
      "birthday": selectedDate,
      "selfInfo": _signatureController.text,
    };
    await ChangeuserApi.submitPersonInfo(context,updatedInfo);
    GlobalUser().user!.setUserName(_nameController.text);
    GlobalUser().user!.setBirthday(selectedDate);
    GlobalUser().user!.setGender(_genderController.text);
    GlobalUser().user!.setSelfIntro(_signatureController.text);
  }

}