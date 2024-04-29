/// {@template bloc}
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
/// Instead of using [State.setState] to update a value, you can use a [BlocProvider],
/// and it'll send a stream of data to any widget that needs it.
/// {@endtemplate}
///
/// The Heart Center is implementing BLoCs using the `provider` package
/// and the [Cubit] class in this file.
library;

import 'dart:async' show StreamController;

import 'package:flutter/foundation.dart' show AsyncCallback;
import 'package:provider/provider.dart' show InheritedProvider, InheritedContext;
export 'package:provider/src/provider.dart' show WatchContext, ReadContext;

/// {@macro bloc}
///
/// This class is a "building bloc" used to define the [Cubit] class.
abstract class Bloc<S> {
  final _controller = StreamController<S>.broadcast();

  /// Sends out a new state using the [_controller].
  void _emit(S newState) {
    if (_controller.isClosed) throw StateError('cannot emit after stream is closed.');
    _controller.add(newState);
  }
}

/// {@template Cubit}
/// A BLoC to use for immutable types.
///
/// This class behaves the same way as the `Cubit` class found at
/// [bloclibrary.dev](https://bloclibrary.dev).
///
/// For mutable types, consider creating your own class with [ChangeNotifier].
/// {@endtemplate}
class Cubit<S> extends Bloc<S> {
  /// {@macro Cubit}
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

/// {@template BlocProvider}
/// A [Cubit] can be used when it's passed into the [MultiProvider] found in `main.dart`.
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
  /// {@macro BlocProvider}
  BlocProvider({super.key, required super.create, super.child, super.builder, super.lazy = true})
      : super(startListening: _startListening, dispose: _dispose);

  static AsyncCallback _startListening(InheritedContext<Bloc?> context, Bloc value) {
    final subscription = value._controller.stream.listen(
      (_) => context.markNeedsNotifyDependents(),
    );

    return subscription.cancel;
  }

  static void _dispose(_, Bloc bloc) => bloc._controller.close();
}
