import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_auth.dart' as auth;
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/widgets/state_async.dart';

enum _Progress { notStarted, loading, done }

class CloseAccount extends StatefulWidget {
  const CloseAccount({super.key});

  @override
  State<CloseAccount> createState() => _CloseAccountState();
}

class _CloseAccountState extends StateAsync<CloseAccount> {
  String password = '';
  String? errorText;
  bool obscureText = true;

  Widget builder(BuildContext context, _) {
    final progress = context.watch<_Deleting>().value;
    final delete = errorText != null || password.isEmpty
        ? null
        : ([_]) async {
            await LocalStorage.password.save(password);
            if (await auth.signIn() case final error?) {
              return safeState(() {
                errorText = error.isEmpty
                    ? 'please double-check your password and try again.'
                    : error;
              });
            }

            if (mounted) await context.read<_Deleting>().delete();
          };

    final textFieldContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To confirm deletion, please type your password in the field below and tap "Confirm".',
          style: StyleText(size: 16),
        ),
        TextField(
          obscureText: obscureText,
          onChanged: (value) {
            setState(() {
              errorText = null;
              password = value;
            });
          },
          onSubmitted: delete,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            errorText: errorText,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => obscureText = !obscureText),
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
          _Progress.done =>
            const Text('You have successfully closed your account.'),
        },
      ),
      actions: [
        if (progress == _Progress.done)
          _ConfirmButton('OK', navigator.logout, key: const Key('confirm'))
        else ...[
          _ConfirmButton('Cancel', navigator.pop),
          _ConfirmButton('Confirm', delete, key: const Key('confirm')),
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
    return BlocProvider(create: (_) => _Deleting(), builder: builder);
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
      child: AnimatedSize(
          duration: Durations.medium1, curve: Curves.ease, child: Text(text)),
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

class _Deleting extends Cubit<_Progress> {
  _Deleting() : super(_Progress.notStarted);

  Future<void> delete() async {
    value = _Progress.loading;
    await user.yeet();
    value = _Progress.done;
  }
}
