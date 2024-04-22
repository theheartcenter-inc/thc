// ignore_for_file: sort_constructors_first

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/utils/bloc.dart';

enum LoginFieldState {
  idName(
    topHint: 'user ID',
    bottomHint: 'First and Last name',
    buttonData: (label: 'sign up with ID', text: 'register'),
  ),
  noID(
    topHint: 'email address',
    buttonData: (label: "don't have an ID?", text: 'register (no ID)'),
  ),
  signIn(
    topHint: 'user ID or email',
    bottomHint: 'password',
    buttonData: (label: 'already registered?', text: 'sign in'),
  ),
  choosePassword(
    topHint: 'choose a password',
    bottomHint: 're-type your password',
  ),
  recovery(
    topHint: 'enter your email',
    buttonData: (label: 'having trouble?', text: 'account recovery'),
  );

  const LoginFieldState({required this.topHint, this.bottomHint, this.buttonData});

  final String topHint;
  final String? bottomHint;
  final ({String label, String text})? buttonData;

  bool get just1field => bottomHint == null;

  (LoginFieldState, LoginFieldState)? get otherOptions => switch (this) {
        idName => (noID, signIn),
        noID => (idName, signIn),
        signIn => (recovery, noID),
        choosePassword || recovery => null,
      };

  LoginFieldState? get back => switch (this) {
        idName => null,
        noID || signIn => idName,
        choosePassword => null,
        recovery => signIn,
      };

  static Future<void> Function() goto(LoginFieldState? target) => () async {
        if (target == null) return;
        LoginProgressTracker.update(fieldState: target);
        await Future.delayed(Durations.medium1);
        if (target.just1field) LoginField.bottom.newVal(null);
        LoginField.top.node.requestFocus();
      };
}

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
      field.node
        ..removeListener(field.listener)
        ..addListener(field.listener);
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
    final LoginProgress(:fieldState, :fieldValues) = readState;

    if (field == LoginField.top && !fieldState.just1field) {
      LoginField.bottom
        ..newVal('')
        ..node.requestFocus();
      return;
    }

    switch (fieldState) {
      case LoginFieldState.idName:
        final (id, name) = fieldValues;
        final doc = await UserCollection.unregisteredUsers.doc(id).get();
        final match = doc.exists && doc['name'] == name;
        update(mismatch: !match);
      case LoginFieldState.noID:
        final maybeEmail = fieldValues.$1!.toLowerCase();
        final valid = EmailValidator.validate(maybeEmail);
        if (!valid) {
          update(mismatch: true);
          return;
        }

      case final fieldState:
        throw UnimplementedError('field: $field, state: $fieldState');
    }
  }

  static MaybeSubmit maybeSubmit([(String?, String?)? fieldValues, bool? mismatch]) {
    if (mismatch ?? readState.mismatch) return null;

    final values = fieldValues ?? readState.fieldValues;
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

typedef MaybeSubmit = Future<void> Function([dynamic])?;
