import 'package:flutter/material.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/utils/bloc.dart';
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

  Widget builder(BuildContext context, _) {
    final progress = context.watch<_Deleting>().state;
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
          onChanged: (value) {
            final correctValue = value == 'DELETE';
            if (canDelete != correctValue) setState(() => canDelete = correctValue);
          },
          onSubmitted: canDelete ? (_) => delete() : null,
          decoration: const InputDecoration(hintText: 'Type DELETE here'),
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
    return BlocProvider(create: (_) => _Deleting(), builder: builder);
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton(this.text, this.onPressed, {super.key});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onPressed = switch (context.watch<_Deleting>().state) {
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

class _Deleting extends Cubit<_Progress> {
  _Deleting() : super(_Progress.notStarted);

  Future<void> delete() async {
    emit(_Progress.loading);
    await user!.yeet();
    emit(_Progress.done);
  }
}
