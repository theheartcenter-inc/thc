import 'package:flutter/widgets.dart';

/// {@template DataWidget}
/// It's like an [InheritedWidget], but it doesn't trigger a rebuild when the [data] changes.
/// {@endtemplate}
final class DataWidget<T> extends ProxyWidget {
  /// {@macro DataWidget}
  const DataWidget({super.key, required this.data, required super.child});

  final T data;

  static T? maybeRead<T>(BuildContext context) =>
      context.findAncestorWidgetOfExactType<DataWidget<T>>()?.data;

  static T read<T>(BuildContext context) => maybeRead(context)!;

  @override
  ComponentElement createElement() => DataElement(this);
}

class DataElement extends ComponentElement {
  DataElement(super.widget);

  @override
  Widget build() => (widget as DataWidget).child;
}
