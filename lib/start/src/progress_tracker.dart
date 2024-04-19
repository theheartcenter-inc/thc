// ignore_for_file: sort_constructors_first

import 'package:flutter/widgets.dart';
import 'package:thc/utils/bloc.dart';

enum LoginMethod { idName, noID, signIn }

typedef LoginButtonData = (LoginMethod, VoidCallback?);

@immutable
class LoginProgress {
  const LoginProgress({
    required this.method,
    required this.pressedStart,
    required this.twoLoginFields,
    required this.showBottom,
  });

  const LoginProgress._initial()
      : method = LoginMethod.idName,
        pressedStart = false,
        twoLoginFields = false,
        showBottom = false;

  LoginProgress copyWith({
    LoginMethod? method,
    bool? pressedStart,
    bool? twoLoginFields,
    bool? showBottom,
  }) {
    return LoginProgress(
      method: method ?? this.method,
      pressedStart: pressedStart ?? this.pressedStart,
      twoLoginFields: twoLoginFields ?? this.twoLoginFields,
      showBottom: showBottom ?? this.showBottom,
    );
  }

  final LoginMethod method;
  final bool pressedStart;
  final bool twoLoginFields;
  final bool showBottom;
}

class LoginProgressTracker extends Cubit<LoginProgress> {
  LoginProgressTracker._() : super(const LoginProgress._initial());

  static final _tracker = LoginProgressTracker._();
  factory LoginProgressTracker.create(_) => _tracker;

  static LoginProgress of(BuildContext context) => context.watch<LoginProgressTracker>().state;

  static void update({
    LoginMethod? method,
    bool? pressedStart,
    bool? twoLoginFields,
    bool? showBottom,
  }) {
    _tracker.emit(_tracker.state.copyWith(
      method: method,
      pressedStart: pressedStart,
      twoLoginFields: twoLoginFields,
      showBottom: showBottom,
    ));
  }
}
