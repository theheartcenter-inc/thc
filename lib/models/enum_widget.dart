import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class _StatelessEnum extends StatelessWidget {
  const _StatelessEnum(this._build);

  final WidgetBuilder _build;

  @override
  Widget build(BuildContext context) => _build(context);
}

mixin StatelessEnum on Enum implements StatelessWidget {
  _StatelessEnum get _statefulEnum => _StatelessEnum(build);

  @override
  Key? get key => null;

  @override
  Widget build(BuildContext context);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.off}) =>
      _statefulEnum.toString(minLevel: minLevel);

  @override
  List<DiagnosticsNode> debugDescribeChildren() => _statefulEnum.debugDescribeChildren();

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) =>
      _statefulEnum.toDiagnosticsNode(name: name, style: style);

  @override
  String toStringShort() => name;

  @override
  String toStringShallow({
    String joiner = ', ',
    DiagnosticLevel minLevel = DiagnosticLevel.debug,
  }) =>
      _statefulEnum.toStringShallow(joiner: joiner, minLevel: minLevel);

  @override
  String toStringDeep({
    String prefixLineOne = '',
    String? prefixOtherLines,
    DiagnosticLevel minLevel = DiagnosticLevel.debug,
  }) =>
      _statefulEnum.toStringDeep(
        prefixLineOne: prefixLineOne,
        prefixOtherLines: prefixOtherLines,
        minLevel: minLevel,
      );

  @override
  StatelessElement createElement() => StatelessElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) =>
      _statefulEnum.debugFillProperties(properties);
}

class _StatefulEnum extends StatefulWidget {
  const _StatefulEnum(this._create);

  final State Function() _create;

  @override
  State createState() => _create(); // ignore: no_logic_in_create_state
}

mixin StatefulEnum on Enum implements StatefulWidget {
  _StatefulEnum get _statefulEnum => _StatefulEnum(createState);

  @override
  Key? get key => null;

  @override
  State<StatefulEnum> createState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.off}) =>
      _statefulEnum.toString(minLevel: minLevel);

  @override
  List<DiagnosticsNode> debugDescribeChildren() => _statefulEnum.debugDescribeChildren();

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) =>
      _statefulEnum.toDiagnosticsNode(name: name, style: style);

  @override
  String toStringShort() => name;

  @override
  String toStringShallow({
    String joiner = ', ',
    DiagnosticLevel minLevel = DiagnosticLevel.debug,
  }) =>
      _statefulEnum.toStringShallow(joiner: joiner, minLevel: minLevel);

  @override
  String toStringDeep({
    String prefixLineOne = '',
    String? prefixOtherLines,
    DiagnosticLevel minLevel = DiagnosticLevel.debug,
  }) =>
      _statefulEnum.toStringDeep(
        prefixLineOne: prefixLineOne,
        prefixOtherLines: prefixOtherLines,
        minLevel: minLevel,
      );

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) =>
      _statefulEnum.debugFillProperties(properties);
}
