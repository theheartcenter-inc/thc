// ignore_for_file: sort_constructors_first

import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_auth.dart' as auth;
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/local_storage.dart';

enum LoginLabels {
  withId(
    topHint: 'user ID',
    bottomHint: 'First and Last name',
    buttonData: (label: 'sign up with ID', text: 'register'),
  ),
  noId(
    topHint: 'email address',
    bottomHint: 'your name',
    buttonData: (label: "don't have an ID?", text: 'register (no ID)'),
  ),
  signIn(
    topHint: 'user ID or email',
    bottomHint: 'password',
    buttonData: (label: 'already registered?', text: 'sign in'),
  ),
  choosePassword(
    topHint: 'choose a password (at least 8 characters)',
    bottomHint: 're-type your password',
  ),
  recovery(
    topHint: 'enter your email',
    buttonData: (label: 'having trouble?', text: 'account recovery'),
  );

  const LoginLabels({required this.topHint, this.bottomHint, this.buttonData});

  final String topHint;
  final String? bottomHint;
  final ({String label, String text})? buttonData;

  bool get just1field => bottomHint == null;
  bool get choosingPassword => this == choosePassword;
  bool get signingIn => this == signIn;

  (LoginLabels, LoginLabels)? get otherOptions => switch (this) {
        withId => (noId, signIn),
        noId => (withId, signIn),
        signIn => (recovery, noId),
        choosePassword || recovery => null,
      };

  LoginLabels? get back => switch (this) {
        withId => null,
        noId || signIn => withId,
        choosePassword => LocalStorage.email() == null ? null : noId,
        recovery => signIn,
      };

  static Future<void> Function() goto(LoginLabels? target) => () async {
        if (target == null) return;
        LoginProgressTracker.update(labels: target);
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
    required this.labels,
    required this.focusedField,
    required this.fieldValues,
    required this.errorMessage,
    required this.showPassword,
  });

  const LoginProgress._initial()
      : labels = LoginLabels.withId,
        focusedField = null,
        animation = AnimationProgress.sunrise,
        errorMessage = null,
        showPassword = false,
        fieldValues = (null, null);

  LoginProgress copyWith({
    required AnimationProgress? animation,
    required LoginLabels? labels,
    required LoginField? focusedField,
    required (String?, String?)? fieldValues,
    required String? errorMessage,
    required bool? showPassword,
  }) {
    return LoginProgress(
      animation: animation ?? this.animation,
      labels: labels ?? this.labels,
      focusedField: focusedField ?? this.focusedField,
      fieldValues: fieldValues ?? this.fieldValues,
      errorMessage: errorMessage ?? this.errorMessage,
      showPassword: showPassword ?? this.showPassword,
    );
  }

  LoginProgress unfocus() => LoginProgress(
        animation: animation,
        labels: labels,
        focusedField: null,
        fieldValues: fieldValues,
        errorMessage: errorMessage,
        showPassword: showPassword,
      );

  LoginProgress resolveError() => LoginProgress(
        animation: animation,
        labels: labels,
        focusedField: focusedField,
        fieldValues: fieldValues,
        errorMessage: null,
        showPassword: showPassword,
      );

  final AnimationProgress animation;
  final LoginLabels labels;
  final LoginField? focusedField;
  final (String?, String?) fieldValues;
  final String? errorMessage;
  final bool showPassword;
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
    LoginLabels? labels,
    LoginField? focusedField,
    AnimationProgress? animation,
    (String?, String?)? fieldValues,
    String? errorMessage,
    bool? showPassword,
  }) {
    if (labels != null && labels != readState.labels) {
      LoginField.controllers
        ..$1.clear()
        ..$2.clear();
      fieldValues = ('', '');
    }

    final progress = fieldValues == null ? readState : readState.resolveError();

    _tracker!.emit(progress.copyWith(
      animation: animation,
      labels: labels,
      focusedField: focusedField,
      fieldValues: fieldValues,
      errorMessage: errorMessage,
      showPassword: showPassword,
    ));
  }

  static void mismatch([String? message]) => update(errorMessage: message ?? '');

  static void toggleShowPassword() => update(showPassword: !readState.showPassword);

  static void unfocus(LoginField field) {
    if (readState.focusedField == field) _tracker!.emit(readState.unfocus());
  }

  static void pop() {
    if (readState.labels.back case final target?) update(labels: target);
  }

  static Future<void> submit(LoginField field) async {
    final LoginProgress(:labels, :fieldValues) = readState;

    if (field == LoginField.top && !labels.just1field) {
      LoginField.bottom
        ..newVal('')
        ..node.requestFocus();
      return;
    }

    switch (labels) {
      case LoginLabels.withId:
        final (id, name) = fieldValues;
        final doc = await Firestore.unregistered.doc(id).get();

        if (!doc.exists || doc['name'] != name) return update(errorMessage: '');

        LocalStorage.userId.save(id);
        LocalStorage.firstLastName.save(name);
        update(labels: LoginLabels.choosePassword);
      case LoginLabels.noId:
        final (email!, name!) = fieldValues;

        if (!EmailValidator.validate(email)) {
          return update(errorMessage: 'double-check the email address and try again.');
        }

        LocalStorage.email.save(email);
        LocalStorage.firstLastName.save(name);
      case LoginLabels.choosePassword:
        final (password!, retype) = fieldValues;
        if (password != retype) {
          return update(errorMessage: "it looks like these passwords don't match.");
        }
        await LocalStorage.password.save(password);

        if (await auth.register() case final errorMessage?) {
          return update(errorMessage: errorMessage);
        }
      case LoginLabels.signIn:
        final (username!, password!) = fieldValues;
        await Future.wait([
          if (username.contains('@'))
            LocalStorage.email.save(username)
          else
            LocalStorage.userId.save(username),
          LocalStorage.password.save(password),
        ]);
        if (await auth.signIn() case final errorMessage?) {
          return update(errorMessage: errorMessage);
        }
      case final labels:
        throw UnimplementedError('field: $field, labels: $labels');
    }

    for (final field in LoginField.values) {
      field.controller.text = '';
    }
  }

  static Future<void> Function([dynamic])? maybeSubmit([
    LoginLabels? labels,
    (String?, String?)? fieldValues,
    bool? error,
  ]) {
    late final state = readState;
    if (error ?? state.errorMessage != null) return null;

    final values = fieldValues ?? state.fieldValues;

    if ((labels ?? state.labels).choosingPassword) {
      if (values case (final a!, final b!) when min(a.length, b.length) < 8) {
        return null; // password too short
      }
    }

    final (field, empty) = switch (values) {
      (final value, null) => (LoginField.top, value?.isEmpty ?? true),
      (final v1, final v2?) => (LoginField.bottom, v1!.isEmpty || v2.isEmpty),
    };

    if (empty) return null;
    return ([_]) => submit(field);
  }
}
