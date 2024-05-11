// ignore_for_file: sort_constructors_first

import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_auth.dart' as auth;
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/utils/local_storage.dart';

/// {@template LoginLabels}
/// Stores [LoginField] hint text & [BottomStuff] labels,
/// and determines the functionality of [LoginProgressTracker.submit].
/// {@endtemplate}
enum LoginLabels {
  /// Register using your user ID and first/last name.
  withId(
    topHint: 'user ID',
    bottomHint: 'First and Last name',
    buttonData: (label: 'sign up with ID', text: 'register'),
  ),

  /// Register using your email address and first/last name.
  noId(
    topHint: 'email address',
    bottomHint: 'your name',
    buttonData: (label: "don't have an ID?", text: 'register (no ID)'),
  ),

  /// Sign into your account with your user ID (or email) and your password.
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

  /// Updates the [LoginProgressTracker] with the relevant [LoginLabels].
  static Future<void> Function() goto(LoginLabels? target) => () async {
        if (target == null) return;
        LoginProgressTracker.update(labels: target);
        await Future.delayed(Durations.medium1);
        if (target.just1field) LoginField.bottom.newVal(null);
        LoginField.top.node.requestFocus();
      };
}

/// {@template start.AnimationProgress}
/// Tracks the state of the animation, from when the app boots up
/// to when the user can type in their info.
/// {@endtemplate}
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

  /// Passing a `null` value into [copyWith] means "don't update this value",
  /// so we gotta make a special function for nulling out the [focusedField].
  LoginProgress unfocus() => LoginProgress(
        animation: animation,
        labels: labels,
        focusedField: null,
        fieldValues: fieldValues,
        errorMessage: errorMessage,
        showPassword: showPassword,
      );

  /// Passing a `null` value into [copyWith] means "don't update this value",
  /// so we gotta make a special function for nulling out the [errorMessage].
  LoginProgress resolveError() => LoginProgress(
        animation: animation,
        labels: labels,
        focusedField: focusedField,
        fieldValues: fieldValues,
        errorMessage: null,
        showPassword: showPassword,
      );

  /// {@macro start.AnimationProgress}
  final AnimationProgress animation;

  /// {@macro LoginLabels}
  final LoginLabels labels;

  final LoginField? focusedField;

  /// Stores what the user typed into the [LoginField]s.
  final (String?, String?) fieldValues;

  /// If hitting the submit button didn't work, this lets the user know what went wrong.
  final String? errorMessage;

  /// While the user is choosing their password,
  /// this value determines whether the text in [LoginField.top] is shown.
  final bool showPassword;
}

/// This is a "singleton class", so it's marked as `final`
/// and has a private constructor to discourage multiple instances.
final class LoginProgressTracker extends ValueNotifier<LoginProgress> {
  LoginProgressTracker._() : super(const LoginProgress._initial());

  static LoginProgressTracker? _tracker;

  /// Accessing the state without a [BuildContext] is super convenient,
  /// but it doesn't trigger a rebuild when something changes.
  static LoginProgress get readState => _tracker!.value;

  factory LoginProgressTracker.create(_) {
    for (final field in LoginField.values) {
      field.node
        ..removeListener(field.listener)
        ..addListener(field.listener);
    }

    return _tracker = LoginProgressTracker._();
  }

  /// This makes retrieving the state from the current [BuildContext] slightly more concise.
  static LoginProgress of(BuildContext context) => context.watch<LoginProgressTracker>().value;

  /// Causes the tracker to [emit] a new progress state.
  ///
  /// And it's accessible without needing a [BuildContext]!
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

    _tracker!.value = progress.copyWith(
      animation: animation,
      labels: labels,
      focusedField: focusedField,
      fieldValues: fieldValues,
      errorMessage: errorMessage,
      showPassword: showPassword,
    );
  }

  static void mismatch([String? message]) => update(errorMessage: message ?? '');

  static void toggleShowPassword() => update(showPassword: !readState.showPassword);

  static void unfocus(LoginField field) {
    if (readState.focusedField == field) _tracker!.value = readState.unfocus();
  }

  /// The current "page" is determined by the [LoginLabels] rather than a [NavigatorState],
  /// so this class has its own `pop()` method.
  static void pop() {
    if (readState.labels.back case final target?) update(labels: target);
  }

  /// The good stuff 😏
  ///
  /// This functionality depends on what the user typed into the [LoginField]s
  /// as well as the current state of the [LoginLabels].
  ///
  /// Usually it involves connecting to Firebase using a function from the [auth] file.
  ///
  /// If something goes wrong, a summary of the issue is sent to [LoginProgress.errorMessage]
  /// for the user to see.
  static Future<String?> submit(LoginField field) async {
    final LoginProgress(:labels, :fieldValues) = readState;

    if (field == LoginField.top && !labels.just1field) {
      LoginField.bottom
        ..newVal('')
        ..node.requestFocus();
      return null;
    }

    String? errorMessage;
    switch (labels) {
      case LoginLabels.withId:
        final (id!, name!) = fieldValues;

        try {
          final user = await ThcUser.download(id);
          if (user.name != name) return '';
          if (user.registered) return 'this user ID is already registered to an account.';
          user.upload();
        } catch (error) {
          return '$error';
        }

        LocalStorage.userId.save(id);
        LocalStorage.firstLastName.save(name);
        update(labels: LoginLabels.choosePassword);

      case LoginLabels.noId:
        final (email!, name!) = fieldValues;

        if (!EmailValidator.validate(email)) {
          return 'double-check the email address and try again.';
        }

        LocalStorage.email.save(email);
        LocalStorage.firstLastName.save(name);
        update(labels: LoginLabels.choosePassword);

      case LoginLabels.choosePassword:
        final (password!, retype) = fieldValues;
        if (password != retype) {
          return "it looks like these passwords don't match.";
        }
        await LocalStorage.password.save(password);
        errorMessage = await auth.register();

      case LoginLabels.signIn:
        final (username!, password!) = fieldValues;
        await Future.wait([
          if (username.contains('@'))
            LocalStorage.email.save(username)
          else
            LocalStorage.userId.save(username),
          LocalStorage.password.save(password),
        ]);
        errorMessage = await auth.signIn();

      case LoginLabels.recovery:
        await LocalStorage.email.save(fieldValues.$1!);
        errorMessage = await auth.resetPassword();
    }

    if (errorMessage != null) return errorMessage;

    for (final field in LoginField.values) {
      field.controller.text = '';
    }
    return null;
  }

  /// Calls [submit] if there's stuff typed into the [LoginField]s;
  /// otherwise does nothing.
  ///
  /// The function parameters are optional since we can just get them from [readState],
  /// but passing them in allows button to rebuild when its enabled/disabled state changes.
  static MaybeSubmit maybeSubmit([
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
    return ([_]) async {
      if (await submit(field) case final errorMessage?) update(errorMessage: errorMessage);
    };
  }
}

/// I made a `typedef` here since `Future<void> Function([dynamic])?` is a lot to type each time.
///
/// It's the same as [AsyncCallback], but it has a single optional parameter that gets ignored
/// to match the function signature for [TextField.onSubmitted].
typedef MaybeSubmit = Future<void> Function([dynamic _])?;
