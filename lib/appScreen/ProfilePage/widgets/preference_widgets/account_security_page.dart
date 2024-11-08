//提供修改密码页面
import 'package:flutter/material.dart';
import 'package:gym_detector_ios/main.dart';
import 'package:gym_detector_ios/module/global_module/global_user.dart';
import 'package:gym_detector_ios/module/person.dart';
import 'package:gym_detector_ios/password_util.dart';
import 'package:gym_detector_ios/widgets/custom_snackbar.dart';

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
            Text("Username: ${user.user_id}", style: TextStyle(fontSize: 20,fontWeight:FontWeight.w600)),
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

  int _step = 1;
  //向后端发邮箱和密码
  Future<void> _submitResetPassword() async {
    try {
      final response = await customHttpClient.put(
        Uri.parse('http://127.0.0.1:4523/m1/5245288-4913049-default/user/password'),
        body: {
          "email": GlobalUser().getUser()!.email,
           "password": PasswordUtil.hashPassword(_confirmPasswordController.text)
        }
            
      );
      if (response.statusCode == 200) {
       
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
                  CustomSnackBar.showFailure(context, "Password Incorrect!");
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
            onPressed: _changePassword,
            child: Text('Confirm'),
          ),
      ],
    );
  }

  Widget _buildStepContent() {
    if (_step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Current Password',
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
            ),
          ),
        ],
      );
    }
  }

  void _changePassword() async{
    if (_newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.isNotEmpty) {
      // 假设密码修改成功
      await _submitResetPassword();
      Navigator.of(context).pop(); // 关闭弹窗
    
    } else {
      // 密码不匹配或为空的处理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match or empty!')),
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
