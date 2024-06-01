import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thc/utils/navigator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isCurrentPasswordCorrect = false;
  bool _isCurrentPasswordVerified = false;
  String _verificationMessage = '';
  Color _messageColor = Colors.black;
  String _passwordError = '';
  bool _isPasswordValid = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateCurrentPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPasswordController.text,
    );

    try {
      await user.reauthenticateWithCredential(cred);
      setState(() {
        _isCurrentPasswordCorrect = true;
        _isCurrentPasswordVerified = true;
        _verificationMessage = 'Verification successful';
        _messageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _isCurrentPasswordCorrect = false;
        _isCurrentPasswordVerified = true;
        _verificationMessage = 'Verification failed';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _validateCurrentPassword,
                child: const Text('Verify Current Password'),
              ),
              if (_isCurrentPasswordVerified)
                Text(
                  _verificationMessage,
                  style: TextStyle(
                      color: _messageColor, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 30),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                enabled:
                    _isCurrentPasswordVerified && _isCurrentPasswordCorrect,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: const TextStyle(color: Colors.black),
                  errorText: _newPasswordController.text.length < 8 &&
                          _newPasswordController.text.isNotEmpty
                      ? 'Password must be at least 8 characters'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isPasswordValid = value.length >= 8;
                    _passwordError = value != _confirmPasswordController.text
                        ? 'Passwords do not match'
                        : '';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                enabled: _isCurrentPasswordVerified &&
                    _isCurrentPasswordCorrect &&
                    _isPasswordValid,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: const TextStyle(color: Colors.black),
                  errorText: _passwordError,
                ),
                onChanged: (value) {
                  setState(() {
                    _passwordError = value != _newPasswordController.text
                        ? 'Passwords do not match'
                        : '';
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_isCurrentPasswordVerified &&
                        _isCurrentPasswordCorrect &&
                        _newPasswordController.text ==
                            _confirmPasswordController.text &&
                        _isPasswordValid)
                    ? _changePassword
                    : null,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePassword() async {
    if (_newPasswordController.text == _currentPasswordController.text) {
      _showPasswordSameDialog();
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    final String newPassword = _newPasswordController.text;

    try {
      await user?.updatePassword(newPassword);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Password Changed'),
            content: const Text('Your password has been successfully changed.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  navigator.logout();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Failed to Change Password'),
            content: Text('Failed to change password: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void _showPasswordSameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password Error'),
          content: const Text(
              'The new password cannot be the same as your current password.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
