/// {@template models.enum_widget}
/// Unlike other Widget classes, you don't pass any arguments into an enum widget.
///
/// Thus, the enum widget `build()` method logic only uses the following:
/// - the current enum value (`a`, `b`, or `c` in the example)
/// - other methods and properties within the enum declaration
/// - anything that can be accessed globally or through the [BuildContext]
/// {@endtemplate}
library;

import 'package:flutter/material.dart';

// ignore_for_file: type_annotate_public_apis, no_logic_in_create_state

/// Enums can implement other classes and use mixins, but they can't extend a class.
/// This makes the enum widget implementation kinda messy,
/// hence the need for the ignores and additional classes.
class _StatelessEnum extends StatelessWidget {
  const _StatelessEnum(this._build);

  final WidgetBuilder _build;

  @override
  Widget build(BuildContext context) => _build(context);
}

/// Allows an enum to become a widget!
///
/// ```dart
/// enum MyEnum with StatelessEnum {
///   a,
///   b,
///   c;
///
///   @override
///   Widget build(BuildContext context) {
///     // ...
///   }
/// }
///
/// // example usage
/// Center(child: MyEnum.a)
/// Column(children: MyEnum.values)
/// ```
///
/// {@macro models.enum_widget}
mixin StatelessEnum on Enum implements StatelessWidget {
  _StatelessEnum get _statefulEnum => _StatelessEnum(build);

  @override
  Key? get key => null;

  @override
  Widget build(BuildContext context);

  @override
  toString({minLevel = DiagnosticLevel.off}) => _statefulEnum.toString(minLevel: minLevel);

  @override
  debugDescribeChildren() => _statefulEnum.debugDescribeChildren();

  @override
  toDiagnosticsNode({name, style}) => _statefulEnum.toDiagnosticsNode(name: name, style: style);

  @override
  toStringShort() => name;

  @override
  toStringShallow({joiner = ', ', minLevel = DiagnosticLevel.debug}) =>
      _statefulEnum.toStringShallow(joiner: joiner, minLevel: minLevel);

  @override
  toStringDeep({prefixLineOne = '', prefixOtherLines, minLevel = DiagnosticLevel.debug}) {
    return _statefulEnum.toStringDeep(
      prefixLineOne: prefixLineOne,
      prefixOtherLines: prefixOtherLines,
      minLevel: minLevel,
    );
  }

  @override
  createElement() => StatelessElement(this);

  @override
  void debugFillProperties(properties) => _statefulEnum.debugFillProperties(properties);
}

class _StatefulEnum extends StatefulWidget {
  const _StatefulEnum(this._create);

  final State Function() _create;

  @override
  State createState() => _create();
}

/// Allows an enum to become a stateful widget!
///
/// ```dart
/// enum MyEnum with StatefulEnum {
///   a,
///   b,
///   c;
///
///   @override
///   State<MyEnum> createState() => _MyEnumState();
/// }
///
/// class _MyEnumState extends State<MyEnum> {
///   @override
///   Widget build(BuildContext context) {
///     // ...
///   }
/// }
///
/// // example usage
/// Center(child: MyEnum.a)
/// Column(children: MyEnum.values)
/// ```
///
/// {@macro models.enum_widget}
mixin StatefulEnum on Enum implements StatefulWidget {
  _StatefulEnum get _statefulEnum => _StatefulEnum(createState);

  @override
  Key? get key => null;

  @override
  State<StatefulEnum> createState();

  @override
  toString({minLevel = DiagnosticLevel.off}) => _statefulEnum.toString(minLevel: minLevel);

  @override
  debugDescribeChildren() => _statefulEnum.debugDescribeChildren();

  @override
  toDiagnosticsNode({name, style}) => _statefulEnum.toDiagnosticsNode(name: name, style: style);

  @override
  toStringShort() => name;

  @override
  toStringShallow({joiner = ', ', minLevel = DiagnosticLevel.debug}) =>
      _statefulEnum.toStringShallow(joiner: joiner, minLevel: minLevel);

  @override
  toStringDeep({prefixLineOne = '', prefixOtherLines, minLevel = DiagnosticLevel.debug}) {
    return _statefulEnum.toStringDeep(
      prefixLineOne: prefixLineOne,
      prefixOtherLines: prefixOtherLines,
      minLevel: minLevel,
    );
  }

  @override
  createElement() => StatefulElement(this);

  @override
  debugFillProperties(properties) => _statefulEnum.debugFillProperties(properties);
}
