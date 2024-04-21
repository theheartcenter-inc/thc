// ignore_for_file: sort_constructors_first

import 'package:flutter/widgets.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/utils/bloc.dart';

enum LoginFieldState { idName, noID, signIn, choosePassword }

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
    required this.fieldState,
    required this.focusedField,
    required this.fieldValues,
    required this.mismatch,
  });

  const LoginProgress._initial()
      : fieldState = LoginFieldState.idName,
        focusedField = null,
        animation = AnimationProgress.sunrise,
        mismatch = false,
        fieldValues = (null, null);

  LoginProgress copyWith({
    required AnimationProgress? animation,
    required LoginFieldState? fieldState,
    required LoginField? focusedField,
    required (String?, String?)? fieldValues,
    required bool? mismatch,
  }) {
    return LoginProgress(
      animation: animation ?? this.animation,
      fieldState: fieldState ?? this.fieldState,
      focusedField: focusedField ?? this.focusedField,
      fieldValues: fieldValues ?? this.fieldValues,
      mismatch: mismatch ?? this.mismatch,
    );
  }

  LoginProgress unfocus() => LoginProgress(
        animation: animation,
        fieldState: fieldState,
        focusedField: null,
        fieldValues: fieldValues,
        mismatch: mismatch,
      );

  final AnimationProgress animation;
  final LoginFieldState fieldState;
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
    LoginFieldState? fieldState,
    LoginField? focusedField,
    AnimationProgress? animation,
    (String?, String?)? fieldValues,
    bool? mismatch,
  }) {
    _tracker!.emit(readState.copyWith(
      animation: animation,
      fieldState: fieldState,
      focusedField: focusedField,
      fieldValues: fieldValues,
      mismatch: mismatch,
    ));
  }

  static void unfocus(LoginField field) {
    if (readState.focusedField == field) _tracker!.emit(readState.unfocus());
  }

  static Future<void> submit(LoginField field) async {
    switch ((field, readState.fieldState)) {
      case (LoginField.top, _):
        LoginField.bottom
          ..newVal('')
          ..node.requestFocus();
      case (LoginField.bottom, LoginFieldState.idName):
        final (id, name) = readState.fieldValues;
        final doc = await UserCollection.unregistered_users.doc(id).get();
        final match = doc.exists && doc['name'] == name;
        update(mismatch: !match);
      case (_, final fieldState):
        throw UnimplementedError('field: $field, state: $fieldState');
    }
  }

  static void Function([dynamic])? maybeSubmit([(String?, String?)? fieldValues]) {
    final values = fieldValues ?? LoginProgressTracker.readState.fieldValues;
    final (field, empty) = switch (values) {
      (final value, null) => (LoginField.top, value?.isEmpty ?? true),
      (final v1, final v2?) => (LoginField.bottom, v1!.isEmpty || v2.isEmpty),
    };

    if (empty) return null;
    return ([_]) => submit(field);
  }

  static late FocusNode topNode;
  static late FocusNode bottomNode;
}
