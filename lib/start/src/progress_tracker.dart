// ignore_for_file: sort_constructors_first

import 'package:flutter/widgets.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/utils/bloc.dart';

enum LoginMethod { idName, noID, signIn }

enum AnimationProgress implements Comparable<AnimationProgress> {
  sunrise,
  pressStart,
  collapseHand,
  showBottom;

  @override
  int compareTo(AnimationProgress other) => index - other.index;

  bool operator >=(AnimationProgress other) => compareTo(other) >= 0;
}

@immutable
class LoginProgress {
  const LoginProgress({
    required this.animation,
    required this.method,
    required this.focusedField,
    required this.twoLoginFields,
    required this.fieldValues,
  });

  const LoginProgress._initial()
      : method = LoginMethod.idName,
        focusedField = null,
        animation = AnimationProgress.sunrise,
        twoLoginFields = false,
        fieldValues = (null, null);

  LoginProgress copyWith({
    required AnimationProgress? animation,
    required LoginMethod? method,
    required LoginField? focusedField,
    required bool? twoLoginFields,
    required (String?, String?)? fieldValues,
  }) {
    return LoginProgress(
      animation: animation ?? this.animation,
      method: method ?? this.method,
      focusedField: focusedField ?? this.focusedField,
      twoLoginFields: twoLoginFields ?? this.twoLoginFields,
      fieldValues: fieldValues ?? this.fieldValues,
    );
  }

  LoginProgress unfocus() => LoginProgress(
        animation: animation,
        method: method,
        focusedField: null,
        twoLoginFields: twoLoginFields,
        fieldValues: fieldValues,
      );

  final AnimationProgress animation;
  final LoginMethod method;
  final LoginField? focusedField;
  final bool twoLoginFields;
  final (String?, String?) fieldValues;
}

final class LoginProgressTracker extends Cubit<LoginProgress> {
  LoginProgressTracker._() : super(const LoginProgress._initial());

  static LoginProgressTracker? _tracker;
  static LoginProgress get readState => _tracker!.state;

  factory LoginProgressTracker.create(_) {
    if (_tracker case final tracker?) return tracker;

    for (final field in LoginField.values) {
      field.node.addListener(field.listener);
    }

    return _tracker = LoginProgressTracker._();
  }

  static LoginProgress of(BuildContext context) => context.watch<LoginProgressTracker>().state;

  static void update({
    LoginMethod? method,
    LoginField? focusedField,
    AnimationProgress? animation,
    bool? twoLoginFields,
    (String?, String?)? fieldValues,
  }) {
    _tracker!.emit(readState.copyWith(
      animation: animation,
      method: method,
      focusedField: focusedField,
      twoLoginFields: twoLoginFields,
      fieldValues: fieldValues,
    ));
  }

  static void unfocus(LoginField field) {
    if (readState.focusedField == field) _tracker!.emit(readState.unfocus());
  }

  static void submit(LoginField field) {
    switch ((field, readState.method)) {
      case (LoginField.top, _):
        update(twoLoginFields: true);
        LoginField.bottom.node.requestFocus();
      case (_, final method):
        throw UnimplementedError('field: $field, method: $method');
    }
  }

  static late FocusNode topNode;
  static late FocusNode bottomNode;
}
