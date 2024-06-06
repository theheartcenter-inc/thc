import 'package:firebase_auth/firebase_auth.dart';
import 'package:thc/the_good_stuff.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool? _passwordCorrect;

  void _validateCurrentPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user?.email! ?? LocalStorage.email()!,
      password: _currentPassword,
    );

    try {
      await user?.reauthenticateWithCredential(cred) ??
          FirebaseAuth.instance.signInWithCredential(cred);
      LocalStorage.password.save(_currentPassword);
      setState(() => _passwordCorrect = true);
    } catch (e) {
      setState(() => _passwordCorrect = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ThcColors.of(context);
    final bool validLength = _newPassword.length >= 8;
    final bool passwordsMatch = _confirmPassword == _newPassword;
    final bool canChange = (_passwordCorrect ?? false) && passwordsMatch && validLength;

    final content = <Widget>[
      TextField(
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Current Password'),
        onChanged: (value) => _currentPassword = value,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: _validateCurrentPassword,
        child: const Text('Verify Current Password'),
      ),
      if (_passwordCorrect case final correct?)
        Text(
          correct ? 'Verification success!' : 'Check your password and try again.',
          style: TextStyle(color: correct ? colors.primary : colors.error, weight: 700),
        ),
      const SizedBox(height: 30),
      TextField(
        obscureText: true,
        enabled: _passwordCorrect ?? false,
        decoration: InputDecoration(
          labelText: 'New Password',
          errorText: _newPassword.isEmpty || validLength
              ? null
              : 'Password must be at least 8 characters',
        ),
        onChanged: (value) => setState(() => _newPassword = value),
      ),
      const SizedBox(height: 16),
      TextField(
        obscureText: true,
        enabled: (_passwordCorrect ?? false) && validLength,
        decoration: InputDecoration(
          labelText: 'Confirm New Password',
          errorText: _confirmPassword.isEmpty || _confirmPassword == _newPassword
              ? null
              : 'Passwords do not match',
        ),
        onChanged: (value) => setState(() => _confirmPassword = value),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: canChange ? _changePassword : null,
        child: const Text('Change Password'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ),
      ),
    );
  }

  void _changePassword() async {
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(_newPassword);
    } catch (e) {
      navigator.snackbarMessage('${e.runtimeType} occurred: $e');
    }
    LocalStorage.password.save(_newPassword);
    navigator.showDialog(const Dialog(
      titleText: 'Password Changed',
      bodyText: 'Your password has been successfully changed.',
    ));
  }
}
