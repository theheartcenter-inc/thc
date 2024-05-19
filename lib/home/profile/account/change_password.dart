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

  // Delete from here
  bool _isTestingMode = false;
  // to here

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validateCurrentPassword);
  }

  void _validateCurrentPassword() async {
    // Delete from here
    if (_isTestingMode) {
      setState(() => _isCurrentPasswordCorrect = true);
      return;
    }
    // to here

    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPasswordController.text,
    );

/*
    try {
      await user.reauthenticateWithCredential(cred);
      setState(() => _isCurrentPasswordCorrect = true);
    } catch (e) {
      setState(() => _isCurrentPasswordCorrect = false);
    }
  }
*/

    // Delete from here
    try {
      await user.reauthenticateWithCredential(cred);
      if (mounted) {
        setState(() => _isCurrentPasswordCorrect = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCurrentPasswordCorrect = false);
      }
    }
  }
  // to here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        // Delete from here
        actions: <Widget>[
          IconButton(
            icon: Icon(_isTestingMode ? Icons.toggle_on : Icons.toggle_off),
            onPressed: () => setState(() => _isTestingMode = !_isTestingMode),
          ),
        ],
        // to here
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                isCorrect: _isCurrentPasswordCorrect,
              ),
              const SizedBox(height: 30),
              _buildPasswordField(
                controller: _newPasswordController,
                labelText: 'New Password',
                enabled: _isCurrentPasswordCorrect,
              ),
              _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                enabled: _isCurrentPasswordCorrect,
              ),
              ElevatedButton(
                onPressed: _isCurrentPasswordCorrect ? _changePassword : null,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    bool isCorrect = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        suffixIcon: controller == _currentPasswordController
            ? Icon(
                isCorrect ? Icons.check : Icons.close,
                color: isCorrect ? Colors.green : Colors.red,
              )
            : null,
      ),
    );
  }

  void _changePassword() async {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      final User? user = FirebaseAuth.instance.currentUser;
      final String newPassword = _newPasswordController.text;

      try {
        await user?.updatePassword(newPassword);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Password Changed'),
              content:
                  const Text('Your password has been successfully changed.'),
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
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Password Mismatch'),
            content:
                const Text('The passwords do not match. Please try again.'),
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
}
