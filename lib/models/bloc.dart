/// ## Business Logic Component (BLoC)
///
/// A [StatefulWidget] has built-in logic: it can react to user input
/// to change the state of the UI.
///
/// A "Business Logic Component" is code that just handles logic
/// without any direct connection to the UI.
///
/// Stateful widgets are great for lots things, but if you had a stateful widget
/// with a "dark mode" switch, it would only change the theme for that screen,
/// not across the whole app. Flutter tries to be efficient and only rebuild a widget
/// when needed, so you could store the theme mode in a global variable that every widget
/// can access, and it still wouldn't update the other screens right away—the theme would
/// abruptly change when something else causes other widgets to rebuild.
///
/// Instead of using [State.setState] to update a value, you can use a [Bloc] for state
/// management, and it'll send a stream of data to any widget that needs it.
///
/// The Heart Center is implementing BLoCs using `provider`,
/// along with some classes borrowed from `flutter_bloc`.
///
/// `provider` a dependency in our pubspec.yaml, and the extra BLoC classes are in this file!
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This class is a "building bloc" used to define other classes in `bloc.dart`.
///
/// The right BLoC to use depends on the situation:
/// - [Cubit] for immutable types
/// - [CubitMutable] for mutable types
/// - [CustomBloc] for more flexibility
abstract class Bloc<S> {
  /// BLoCs need a way to emit changes into a widget's build context;
  /// that's what this [StreamController] is for.
  StreamController<S> get _streamController;
}

/// This class is used in both [Cubit] and [CubitMutable].
///
/// A data type is "immutable" if the only way to update it
/// is by assigning it a new value. Some examples:
/// ```dart
/// int, double, bool, String
/// ```
///
/// Mutable types can change without being reassigned.
/// ```
/// List, Map, Set
/// ```
abstract class StateBloc<S> extends Bloc<S> {
  @override
  final _streamController = StreamController<S>.broadcast();

  /// Sends out a new state using the [_streamController].
  void _emit(S newState) {
    if (_streamController.isClosed) throw StateError('cannot emit after stream is closed.');
    _streamController.add(newState);
  }
}

/// {@template models.bloc.Cubit}
/// A BLoC to use for immutable types.
///
/// This class behaves the same way as the `Cubit` class found at
/// [bloclibrary.dev](https://bloclibrary.dev).
///
/// For mutable types, consider using [CubitMutable].
/// {@endtemplate}
class Cubit<S> extends StateBloc<S> {
  /// {@macro models.bloc.Cubit}
  Cubit(S state) : _state = state;

  S _state;

  /// The [Cubit]'s current value.
  ///
  /// This value is read-only, and is updated when
  /// a new value is passed to [emit].
  S get state => _state;

  void emit(S newState) {
    if (newState == state) return;
    _state = newState;
    _emit(newState);
  }
}

/// {@template models.bloc.CubitMutable}
/// Similar to [Cubit], but designed for mutable types.
///
/// Listening widgets are rebuilt each time [emit] is called.
/// {@endtemplate}
class CubitMutable<S> extends StateBloc<S> {
  /// {@macro models.bloc.CubitMutable}
  CubitMutable(this.state);

  S state;

  /// Since there isn't an immutable value to compare with,
  /// it's tough to figure out whether changes have been made
  /// and listening widgets should rebuild.
  ///
  /// So instead, [CubitMutable.emit] triggers a rebuild every time,
  /// using the current [state].
  void emit() => _emit(state);
}

/// The goal of `CustomBloc` is to be as flexible as possible.
///
/// If you're making a model with a bunch of different values that interact,
/// instead wrapping everything in a huge class, you can set each value
/// globally with its own `CustomBloc`: this can give a performance boost,
/// since splitting into multiple streams means you don't rebuild everything
/// whenever there's an update.
///
/// ```dart
/// int value = 1; // current value can be accessed by another BLoC if needed
/// final _valueController = StreamController<int>.broadcast();
///
/// class ValueBloc extends CustomBloc<int> {
///   @override
///   StreamController<int> get controller => _valueController;
///
///   void doubleIt() => controller.add(value = value * 2);
/// }
/// ```
abstract class CustomBloc<S> extends Bloc<S> {
  StreamController<S> get controller;
  @override
  StreamController<S> get _streamController => controller;
}

/// {@template models.bloc.BlocProvider}
/// A [Bloc] can be used when it's passed into the [MultiProvider] found in `main.dart`.
///
/// ```dart
/// MultiProvider(
///   providers: [
///     BlocProvider(create: (_) => Bloc1()),
///     BlocProvider(create: (_) => Bloc2()),
///     BlocProvider(create: (_) => Bloc3()),
///   ],
/// )
/// ```
/// {@endtemplate}
class BlocProvider<T extends Bloc> extends InheritedProvider<T> {
  /// {@macro models.bloc.BlocProvider}
  BlocProvider({super.key, required super.create, super.child, super.lazy = true})
      : super(startListening: _startListening, dispose: _dispose);

  static void _dispose(BuildContext _, Bloc bloc) => bloc._streamController.close();

  static VoidCallback _startListening(InheritedContext<Bloc?> context, Bloc value) =>
      value._streamController.stream.listen((_) => context.markNeedsNotifyDependents()).cancel;
}
