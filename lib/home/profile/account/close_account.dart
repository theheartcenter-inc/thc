import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';

enum _Progress { notStarted, loading, done }

class CloseAccount extends StatefulWidget {
  const CloseAccount({super.key});

  @override
  State<CloseAccount> createState() => _CloseAccountState();
}

class _CloseAccountState extends State<CloseAccount> {
  bool canDelete = false;
  bool _obscureText = true;

  Widget builder(BuildContext context, _) {
    final progress = context.watch<_Deleting>().value;
    Future<void> delete() => context.read<_Deleting>().delete();

    final textFieldContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To confirm deletion, please type "DELETE" in the field below and tap "Confirm".',
          style: StyleText(size: 16),
        ),
        TextField(
          obscureText: _obscureText,
          onChanged: (value) async {
            final correctValue = await context.read<_Deleting>().checkPassword(value);
            if (canDelete != correctValue) setState(() => canDelete = correctValue);
          },
          onSubmitted: canDelete ? (_) => delete() : null,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );

    final dialog = AlertDialog(
      title: const Text('Close Account'),
      content: AnimatedSize(
        duration: Durations.medium1,
        curve: Curves.ease,
        child: switch (progress) {
          _Progress.notStarted => textFieldContent,
          _Progress.loading => _Loading(textFieldContent),
          _Progress.done => const Text('You have successfully closed your account.'),
        },
      ),
      actions: [
        if (progress == _Progress.done)
          _ConfirmButton('OK', navigator.logout, key: const Key('confirm'))
        else ...[
          _ConfirmButton('Cancel', navigator.pop),
          _ConfirmButton('Confirm', canDelete ? delete : null, key: const Key('confirm')),
        ],
      ],
    );

    return AbsorbPointer(
      absorbing: progress == _Progress.loading,
      child: SizedBox.expand(child: Center(child: dialog)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => _Deleting(), builder: builder);
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton(this.text, this.onPressed, {super.key});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onPressed = switch (context.watch<_Deleting>().value) {
      _Progress.notStarted || _Progress.done => this.onPressed,
      _Progress.loading => null,
    };

    return ElevatedButton(
      onPressed: onPressed,
      child: AnimatedSize(duration: Durations.medium1, curve: Curves.ease, child: Text(text)),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const indicator = RefreshProgressIndicator(
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [Opacity(opacity: 0.25, child: child), indicator],
    );
  }
}

class _Deleting extends ValueNotifier<_Progress> {
  _Deleting() : super(_Progress.notStarted);

  Future<void> delete() async {
    value = _Progress.loading;
    await user.yeet();
    value = _Progress.done;
  }

  Future<bool> checkPassword(String inputPassword) async {
    // Replace this with the actual logic to verify the user's password
    final storedPassword = await getUserPassword(); // Fetch the actual user password
    return inputPassword == storedPassword;
  }

  Future<String> getUserPassword() async {
    // Fetch the user password from your authentication service
    return 'user_actual_password';
  }
}
