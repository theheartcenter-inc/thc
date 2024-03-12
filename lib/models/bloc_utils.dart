/// ## Business Logic Component (BLoC)
///
/// A BLoC is perfect for times when changing a single value
/// should affect multiple screens in the app.
///
/// BLoCs can be implemented using Flutter's built-in `ChangeNotifier`
/// class, or using third-party libraries like `riverpod` and `flutter_bloc`.
///
/// The Heart Center is using the `flutter_bloc` library, which contains
/// helpful classes like `Cubit` and `BlocProvider`. (It also has a `Bloc` class,
/// but let's avoid that one since it involves a lot of spaghetti code.)
///
/// The best BLoC to use depends on the situation:
/// - [Cubit], for immutable types
/// - [MutaBloc], for mutable types
/// - [GloBloc], to interact with data from other BLoCs
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// private class, used to create the other classes in this file.
abstract class _BlocStream<S> implements StateStreamableSource<S> {
  StreamController<S> get _controller;
  @override
  Stream<S> get stream => _controller.stream;
  @override
  bool get isClosed => _controller.isClosed;
  @override
  void close() => _controller.close();
}

/// {@template MutaBloc}
/// If [S] is a mutable type, then [Cubit.emit] might not capture changes.
///
/// [MutaBloc.emit] always triggers a rebuild, using the current [state].
/// {@endtemplate}
abstract class MutaBloc<S> extends _BlocStream<S> {
  /// {@macro MutaBloc}
  MutaBloc(this.state);

  @override
  S state;

  @override
  final _controller = StreamController<S>.broadcast();

  /// {@macro MutaBloc}
  void emit() => isClosed
      ? throw StateError('emit() called after stream was closed.')
      : _controller.add(state);
}

/// This is a “global” BLoC—the [state] can exist outside of the class declaration.
///
/// Using multiple [GloBloc]s instead of one big class can boost perfomance,
/// since UI elements are rebuilt based on the stream they're subscribed to.
///
/// Unlike other BLoCs, it isn't designed to support multiple instances
/// with different states.
///
/// ```dart
/// class SomeValueBloc extends GloBloc<SomeClass> {
///   @override
///   SomeClass get state => someValue;
///   @override
///   StreamController<SomeClass> get controller => _controller;
/// }
/// final _controller = StreamController<SomeClass>.broadcast();
///
/// var someValue = SomeClass();
/// void emit(SomeClass newValue) {
///   if (newValue == someValue) return;
///   someValue = newValue;
///   _controller.add(newValue);
/// }
/// ```
abstract class GloBloc<S> extends _BlocStream<S> {
  @override
  S get state;

  StreamController<S> get controller;

  @override
  StreamController<S> get _controller => controller;
}
