// ignore_for_file: sort_constructors_first

import 'package:flutter/widgets.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/utils/bloc.dart';

enum LoginMethod { idName, noID, signIn, choosePassword }

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
    required this.fieldValues,
    required this.mismatch,
  });

  const LoginProgress._initial()
      : method = LoginMethod.idName,
        focusedField = null,
        animation = AnimationProgress.sunrise,
        mismatch = false,
        fieldValues = (null, null);

  LoginProgress copyWith({
    required AnimationProgress? animation,
    required LoginMethod? method,
    required LoginField? focusedField,
    required (String?, String?)? fieldValues,
    required bool? mismatch,
  }) {
    return LoginProgress(
      animation: animation ?? this.animation,
      method: method ?? this.method,
      focusedField: focusedField ?? this.focusedField,
      fieldValues: fieldValues ?? this.fieldValues,
      mismatch: mismatch ?? this.mismatch,
    );
  }

  LoginProgress unfocus() => LoginProgress(
        animation: animation,
        method: method,
        focusedField: null,
        fieldValues: fieldValues,
        mismatch: mismatch,
      );

  final AnimationProgress animation;
  final LoginMethod method;
  final LoginField? focusedField;
  final (String?, String?) fieldValues;
  final bool mismatch;
}

final class LoginProgressTracker extends Cubit<LoginProgress> {
  LoginProgressTracker._() : super(const LoginProgress._initial());

  static LoginProgressTracker? _tracker;
  static LoginProgress get readState => _tracker!.state;

  factory LoginProgressTracker.create(_) {
    for (final field in LoginField.values) {
      // ignore: invalid_use_of_protected_member
      if (!field.node.hasListeners) field.node.addListener(field.listener);
    }

    return _tracker = LoginProgressTracker._();
  }

  static LoginProgress of(BuildContext context) => context.watch<LoginProgressTracker>().state;

  static void update({
    LoginMethod? method,
    LoginField? focusedField,
    AnimationProgress? animation,
    (String?, String?)? fieldValues,
    bool? mismatch,
  }) {
    _tracker!.emit(readState.copyWith(
      animation: animation,
      method: method,
      focusedField: focusedField,
      fieldValues: fieldValues,
      mismatch: mismatch,
    ));
  }

  static void unfocus(LoginField field) {
    if (readState.focusedField == field) _tracker!.emit(readState.unfocus());
  }

  static Future<void> submit(LoginField field) async {
    switch ((field, readState.method)) {
      case (LoginField.top, _):
        LoginField.bottom
          ..newVal('')
          ..node.requestFocus();
      case (LoginField.bottom, LoginMethod.idName):
        final (id, name) = readState.fieldValues;
        final doc = await UserCollection.unregistered_users.doc(id).get();
        final match = doc.exists && doc['name'] == name;
        update(mismatch: !match);
      case (_, final method):
        throw UnimplementedError('field: $field, method: $method');
    }
  }

  static void Function([dynamic])? maybeSubmit([(String?, String?)? fieldValues]) {
    final values = fieldValues ?? LoginProgressTracker.readState.fieldValues;
    final (field, value) = switch (values) {
      (final value, null) => (LoginField.top, value),
      (_, final value) => (LoginField.bottom, value),
    };

    if (value?.isEmpty ?? true) return null;
    return ([_]) => submit(field);
  }

  static late FocusNode topNode;
  static late FocusNode bottomNode;
}
