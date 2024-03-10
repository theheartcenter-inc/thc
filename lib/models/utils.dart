import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// If the type [S] changes via mutation rather than reassignment,
/// the normal [emit] method is prone to fail.
///
/// Classes that extend [BroadcastBloc] can be used in a [BlocProvider],
/// but [BroadcastBloc.emit] should be used with caution,
/// since unlike other [Bloc] classes it always triggers a rebuild.
class BroadcastBloc<S> implements StateStreamableSource<S> {
  BroadcastBloc(this.state);

  @override
  S state;

  late final _controller = StreamController<S>.broadcast();
  void emit() => _controller.add(state);

  @override
  void close() => _controller.close();
  @override
  bool get isClosed => _controller.isClosed;
  @override
  Stream<S> get stream => _controller.stream;
}
