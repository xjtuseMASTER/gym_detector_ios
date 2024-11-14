//提供修改密码页面
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/cache_module/person.dart';
import 'package:gym_detector_ios/services/utils/password_util.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';
import 'package:gym_detector_ios/widgets/http.dart';

class AccountSecurityPage extends StatelessWidget {
  final Person user =GlobalUser().getUser()!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Security',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF755DC1))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Email: ${user.email}", style: TextStyle(fontSize: 20,fontWeight:FontWeight.w600)),
            SizedBox(height: 10),
            Text("Username: ${user.user_name}", style: TextStyle(fontSize: 20,fontWeight:FontWeight.w600)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog(context);
                },
                child: Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PasswordChangeDialog();
      },
    );
  }
}

class _PasswordChangeDialog extends StatefulWidget {
  @override
  _PasswordChangeDialogState createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool showError=false;//旧密码是否正确
  bool showNotMatch=false;//新密码是否相同
  bool showisNotValid=false;//新密码是否符合标准
  int _step = 1;
  bool _isObscure1 = true;//旧密码是否可见
  bool _isObscure2 = true;//新密码是否可见
  bool _isObscure3 = true;//重复新密码是否可见
  //向后端发邮箱和密码
  Future<void> _submitResetPassword(BuildContext context) async {
    if (_newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.isNotEmpty) {
      //判断密码是否符合标准
      if(_newPasswordController.text.length<8)
      {
        setState(() {
          showNotMatch=false;
          showisNotValid=true;
        });
      }else{
        //向后端发请求改密码
        try {
        final response = await customHttpClient.put(
          Uri.parse('${Http.httphead}/user/password'),
          body: jsonEncode({
            "user_id": GlobalUser().getUser()!.user_id,
            "email": GlobalUser().getUser()!.email,
            "password": PasswordUtil.hashPassword(_confirmPasswordController.text),
          }),
        );
        if (response.statusCode == 200) {
          Navigator.of(context).pop(); // 关闭弹窗
          _showSuccessDialog();


        } else {
          String errorMessage;
          if (response.statusCode == 404) {
            errorMessage = 'Resource not found';
          } else if (response.statusCode == 500) {
            errorMessage = 'Server error';
          } else if (response.statusCode == 403) {
            errorMessage = 'Permission denied';
          } else {
            errorMessage = 'Unknown error';
          }
        
          CustomSnackBar.showFailure(context, errorMessage);
        }
      } catch (e) {

        CustomSnackBar.showFailure(context, 'Network Error: Cannot fetch data');
      }
    }
    } else {
      // 前后两次密码不相同的处理
      setState(() {
        showisNotValid=false;
        showNotMatch=true;
      });      
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Password'),
      content: _buildStepContent(),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 取消并关闭弹窗
          },
          child: Text('Cancel'),
        ),
        if (_step == 1)
          TextButton(
            onPressed: () {
              //验证旧密码是否正确
              if (_currentPasswordController.text.isNotEmpty) {
                
                if(PasswordUtil.hashPassword(_currentPasswordController.text!)==GlobalUser().getUser()!.password){
                setState(() {
                  _step = 2; // 切换到下一步
                });
                }
                else{
                  setState(() {
                    showError=true;
                  });
                }

              }
              else{
                CustomSnackBar.showFailure(context, "please input your password!");
              }
            },
            child: Text('Next'),
          ),
        if (_step == 2)
          TextButton(
            onPressed: () async {
              await _submitResetPassword(context);
            },
            child: Text('Confirm'),
          ),
      ],
    );
  }

  Widget _buildStepContent() {
    //第一步验证旧密码
    if (_step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: _isObscure1,
            decoration: InputDecoration(
              labelText: 'Current Password',
               //控制密码是否可见
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure1 ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure1 = !_isObscure1;
                  });
                },
              ),
            ),
            inputFormatters: [
                 FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Visibility(
            visible: showError, // 控制是否显示错误消息
            child: Text(
              'Password incorrect',
              style: TextStyle(color: Colors.red), // 设置错误消息的样式
            ),
          ),
        ],
      );
    } else {
      //第二步输入新密码
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _newPasswordController,
            obscureText: _isObscure2,
            decoration: InputDecoration(
              labelText: 'New Password',
              //控制密码是否可见
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure2 ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure2 = !_isObscure2;
                  });
                },
              ),
            ),
            //只允许输入字符不允许输入文字
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _isObscure3,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
                 //控制密码是否可见
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure3 ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure3 = !_isObscure3;
                  });
                },
              ),
            ),
            //只允许输入字符不允许输入文字
            inputFormatters: [
                 FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Visibility(
            visible: showNotMatch, // 控制是否显示错误消息
            child: Text(
              'The two passwords are different',
              style: TextStyle(color: Colors.red), // 设置错误消息的样式
            ),
          ),
          Visibility(
            visible: showisNotValid, // 控制是否显示错误消息
            child: Text(
              'Password at least 8 characters long！',
              style: TextStyle(color: Colors.red), // 设置错误消息的样式
            ),
          ),
        ],
      );
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Password changed successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭成功提示弹窗
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
