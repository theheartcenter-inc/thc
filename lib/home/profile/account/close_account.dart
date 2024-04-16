import 'package:flutter/material.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/utils/navigator.dart';

class _DeleteSuccess extends StatelessWidget {
  const _DeleteSuccess();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account Closed'),
      content: const Text('You have successfully closed your account.'),
      actions: [
        ElevatedButton(onPressed: () => navigator.logout(), child: const Text('OK')),
      ],
    );
  }
}

class CloseAccount extends StatefulWidget {
  const CloseAccount({super.key});

  @override
  State<CloseAccount> createState() => _CloseAccountState();
}

class _CloseAccountState extends State<CloseAccount> {
  bool canDelete = false;

  VoidCallback? get delete {
    if (!canDelete) return null;

    void disableTouch() => navigator.showDialog(
          const SizedBox.shrink(),
          barrierColor: Colors.transparent,
          barrierDismissible: false,
        );

    return () async {
      navigator.pop();
      disableTouch();
      await user!.yeet();
      navigator.showDialog(const _DeleteSuccess(), barrierDismissible: false);
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Close Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To confirm deletion, please type "DELETE" in the field below and tap "Confirm".',
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            onChanged: (value) {
              final correctValue = value == 'DELETE';
              if (canDelete != correctValue) setState(() => canDelete = correctValue);
            },
            decoration: const InputDecoration(
              hintText: 'Type DELETE here',
              labelText: 'Confirmation',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(onPressed: navigator.pop, child: const Text('Cancel')),
        ElevatedButton(onPressed: delete, child: const Text('Confirm')),
      ],
    );
  }
}
