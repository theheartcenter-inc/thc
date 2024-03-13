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
/// `provider` is a dependency in our pubspec.yaml, and the extra BLoC classes are in this file!
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This class is a "building bloc" used to define other classes in `bloc.dart`.
///
/// The right BLoC to use depends on the situation:
/// - [Cubit] for immutable types
/// - [Claybit] for mutable types
/// - [CustomBloc] for the most flexibility
abstract class Bloc<S> {
  /// BLoCs need a way to emit changes into a widget's build context;
  /// that's what this [StreamController] is for.
  StreamController<S> get _streamController;
}

/// This class is used in both [Cubit] and [Claybit].
///
/// ```dart
/// int, double, bool, String // immutable types
/// List, Map, Set            // mutable types
/// ```
/// Immutable types (usually) won't change unless they're reassigned.
///
/// Mutable types can "mutate" even if they're declared as `final`.
///
/// Example:
///
/// ```dart
/// String string = 'cat';
/// string[0] = 'f'; // error, can't change parts of a String
///
/// // reassigning the whole string works, since it isn't final
/// string = 'f${string.substring(1)}'; // string is 'fat' now
///
/// final List list = [1, 2, 3];
/// list[0] = 5; // works fine
///
///
/// // This class is "immutable" even though its member can change.
/// @immutable
/// class ListWrapper {
///   const Class(this.list);
///   final List list;
/// }
///
/// class ListCubit extends Claybit<ListWrapper> {
///   // probably better than Cubit.
/// }
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
/// For mutable types, consider using [Claybit].
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
class Claybit<S> extends StateBloc<S> {
  /// {@macro models.bloc.CubitMutable}
  Claybit(this.state);

  /// The claybit's current value.
  ///
  /// It can be reassigned, or changed in other ways
  /// (e.g. for a [List], you could do `state.add(5)`).
  S state;

  /// Since there isn't an immutable value to compare with,
  /// it's tough to figure out whether changes have been made
  /// and listening widgets should rebuild.
  ///
  /// So instead, [Claybit.emit] triggers a rebuild every time,
  /// using the current [state].
  void emit() => _emit(state);
}

/// [Claybit]s can be molded in many ways, but a `CustomBloc` is even more flexible.
///
/// If you're making a model with a bunch of different values that interact,
/// instead wrapping everything in a huge class, you can set each value
/// globally with its own `CustomBloc`: this can give a performance boost,
/// since splitting into multiple streams means you don't rebuild everything
/// whenever there's an update.
///
/// ```dart
/// final _valueController = StreamController<int>.broadcast();
/// int value = 1; // current value can be accessed without a BuildContext,
///                // but you still need the context to listen for changes
///
/// // this function can be called directly from a widget, or from another BLoC!
/// void doubleIt() => controller.add(value = value * 2);
///
/// class ValueBloc extends CustomBloc<int> {
///   @override
///   StreamController<int> get controller => _valueController;
/// }
/// ```
abstract class CustomBloc<S> extends Bloc<S> {
  /// This object can send a value to whatever widgets are listening.
  ///
  /// [controller] can be defined inside or outside the class.
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

  static VoidCallback _startListening(InheritedContext<Bloc?> context, Bloc value) =>
      value._streamController.stream.listen((_) => context.markNeedsNotifyDependents()).cancel;

  static void _dispose(BuildContext _, Bloc bloc) => bloc._streamController.close();
}
