import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Close Account'),
      content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await deleteAccount(context);
            Navigator.of(context).pop();
          },
          child: const Text('Delete Account'),
        ),
      ],
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Prompt the user for their password
        final password = await _showPasswordDialog(context);

        if (password != null) {
          // Re-authenticate the user
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );

          await user.reauthenticateWithCredential(credential);

          // Delete user data from Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

          // Delete the user's account from Firebase Auth
          await user.delete();

          // Log out the user
          await FirebaseAuth.instance.signOut();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account successfully deleted')),
          );

          // Optionally navigate to a login or home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    String? password;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                password = controller.text;
                Navigator.of(context).pop(password);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return password;
  }
}
