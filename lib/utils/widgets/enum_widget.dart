/// {@template enum_widget}
/// Unlike other Widget classes, you don't pass any arguments into an enum widget.
///
/// Thus, the enum widget `build()` method logic only uses the following:
/// - the current enum value (`a`, `b`, or `c` in the example)
/// - other methods and properties within the enum declaration
/// - anything that can be accessed globally or through the [BuildContext]
/// {@endtemplate}
library;

import 'package:flutter/foundation.dart' show DiagnosticableTreeNode;
import 'package:flutter/material.dart';
import 'package:thc/utils/bloc.dart';

// ignore_for_file: type_annotate_public_apis, no_logic_in_create_state

/// Allows an enum to act as a widget.
///
/// ```dart
/// enum MyEnum with StatelessEnum {
///   a,
///   b,
///   c;
///
///   @override
///   Widget build(BuildContext context) {
///     // enum build method!
///   }
/// }
///
/// // example usage
/// Center(child: MyEnum.a)
/// Column(children: MyEnum.values)
/// ```
///
/// {@macro enum_widget}
mixin EnumStatelessWidgetMixin on Enum implements StatelessWidget {
  Widget get _widget => Builder(builder: build);

  @override
  get key => Key(name);

  @override
  toString({minLevel = DiagnosticLevel.off}) => _widget.toString(minLevel: minLevel);

  @override
  debugDescribeChildren() => const <DiagnosticsNode>[];

  @override
  toDiagnosticsNode({name, style}) =>
      DiagnosticableTreeNode(name: this.name, value: this, style: style);

  @override
  toStringShort() => '$runtimeType-$key';

  @override
  toStringShallow({joiner = ', ', minLevel = DiagnosticLevel.debug}) =>
      _widget.toStringShallow(joiner: joiner, minLevel: minLevel);

  @override
  toStringDeep({prefixLineOne = '', prefixOtherLines, minLevel = DiagnosticLevel.debug}) {
    return toDiagnosticsNode().toStringDeep(
      prefixLineOne: prefixLineOne,
      prefixOtherLines: prefixOtherLines,
      minLevel: minLevel,
    );
  }

  @override
  createElement() => StatelessElement(this);

  @override
  void debugFillProperties(properties) => _widget.debugFillProperties(properties);
}

/// {@macro enum_widget}
mixin EnumHookWidgetMixin on Enum implements HookWidget {
  HookWidget get _widget => HookBuilder(builder: build);

  @override
  get key => Key(name);

  @override
  toString({minLevel = DiagnosticLevel.off}) => _widget.toString(minLevel: minLevel);

  @override
  debugDescribeChildren() => const <DiagnosticsNode>[];

  @override
  toDiagnosticsNode({name, style}) =>
      DiagnosticableTreeNode(name: this.name, value: this, style: style);

  @override
  toStringShort() => '$runtimeType-$key';

  @override
  toStringShallow({joiner = ', ', minLevel = DiagnosticLevel.debug}) =>
      _widget.toStringShallow(joiner: joiner, minLevel: minLevel);

  @override
  toStringDeep({prefixLineOne = '', prefixOtherLines, minLevel = DiagnosticLevel.debug}) {
    return toDiagnosticsNode().toStringDeep(
      prefixLineOne: prefixLineOne,
      prefixOtherLines: prefixOtherLines,
      minLevel: minLevel,
    );
  }

  @override
  createElement() => _widget.createElement();

  @override
  void debugFillProperties(properties) => _widget.debugFillProperties(properties);
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
/// {@macro enum_widget}
mixin EnumStatefulWidgetMixin on Enum implements StatefulWidget {
  _StatefulEnum get _statefulEnum => _StatefulEnum(createState);

  @override
  get key => Key(name);

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
