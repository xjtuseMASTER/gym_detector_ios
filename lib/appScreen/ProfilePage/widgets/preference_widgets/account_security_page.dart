//提供修改密码页面
import 'package:flutter/material.dart';

class AccountSecurityPage extends StatelessWidget {
  final String email = "1192597201.com"; // 当前用户的邮箱
  final String username = "1192597201";   // 当前用户的账号

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
            Text("Email: $email", style: TextStyle(fontSize: 20,fontWeight:FontWeight.w600)),
            SizedBox(height: 10),
            Text("Username: $username", style: TextStyle(fontSize: 20,fontWeight:FontWeight.w600)),
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
              if (_currentPasswordController.text.isNotEmpty) {
                setState(() {
                  _step = 2; // 切换到下一步
                });
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

  void _changePassword() {
    if (_newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.isNotEmpty) {
      // 假设密码修改成功
      Navigator.of(context).pop(); // 关闭弹窗
      _showSuccessDialog();
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
