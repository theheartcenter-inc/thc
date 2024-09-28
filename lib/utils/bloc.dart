import 'dart:async' show Timer;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:thc/main.dart';

export 'package:provider/provider.dart' hide Dispose, ChangeNotifierProvider;

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;
typedef BlocProvider<T extends Bloc?> = ChangeNotifierProvider<T>;

extension ToggleCubit on Cubit<bool> {
  void toggle() => value = !value;
}

extension ToggleRef on ObjectRef<bool> {
  void toggle() => value = !value;
}

extension UpdateCubit<T> on Cubit<T> {
  void update(T? newValue) => value = newValue as T;
}

extension UpdateRef<T> on ObjectRef<T> {
  void update(T? newValue) => value = newValue as T;
}

/// {@template Editing}
/// By passing this into the [MultiProvider] in [App.build],
/// any widget can see whether we're in "editing mode" by calling [Editing.of].
/// {@endtemplate}
class Editing extends Cubit<bool> {
  /// {@macro Editing}
  Editing([super.initialValue = false]);

  /// {@macro Editing}
  static bool of(BuildContext context) => context.watch<Editing>().value;
}

class Loading extends Cubit<bool> {
  Loading() : super(false);

  static bool of(BuildContext context) => context.watch<Loading>().value;
}

extension Powers<T extends num> on T {
  T get squared => this * this as T;
  T get cubed => this * this * this as T;
}

/// A [callback] can be passed to [useOnce], and it will only trigger
/// when the hook is initialized.
void useOnce(VoidCallback callback) => use(_SingleUseHook(callback));

class _SingleUseHook extends Hook<void> {
  const _SingleUseHook(this.callback);

  final VoidCallback callback;

  @override
  _SingleUseHookState createState() => _SingleUseHookState();
}

class _SingleUseHookState extends HookState<void, _SingleUseHook> {
  @override
  void initHook() => hook.callback();

  @override
  void build(BuildContext context) {}
}

Timer useTimer(Duration duration, VoidCallback callback) => use(_TimerHook(duration, callback));

class _TimerHook extends Hook<Timer> {
  const _TimerHook(this.duration, this.callback);

  final Duration duration;
  final VoidCallback callback;

  @override
  _TimerHookState createState() => _TimerHookState();
}

class _TimerHookState extends HookState<Timer, _TimerHook> {
  late final Timer _timer;

  @override
  void initHook() => _timer = Timer(hook.duration, hook.callback);

  @override
  Timer build(BuildContext context) => _timer;

  @override
  void dispose() => _timer.cancel();
}

FormKey useFormKey() => useMemoized(FormKey.new);

extension type FormKey._(GlobalKey<FormState> _globalKey) implements Key {
  FormKey([String? debugLabel]) : _globalKey = GlobalKey<FormState>(debugLabel: debugLabel);

  FormState get _form => _globalKey.currentState!;

  /// Saves every [FormField] that is a descendant of this [Form].
  void save() => _form.save();

  /// Resets every [FormField] that is a descendant of this [Form] back to its
  /// [FormField.initialValue].
  ///
  /// The [Form.onChanged] callback will be called.
  ///
  /// If the form's [Form.autovalidateMode] property is [AutovalidateMode.always],
  /// the fields will all be revalidated after being reset.
  void reset() => _form.reset();

  /// Validates every [FormField] that is a descendant of this [Form], and
  /// returns true if there are no errors.
  ///
  /// The form will rebuild to report the results.
  ///
  /// See also:
  ///  * [validateGranularly], which also validates descendant [FormField]s,
  /// but instead returns a [Set] of fields with errors.
  bool validate() => _form.validate();

  /// Validates every [FormField] that is a descendant of this [Form], and
  /// returns a [Set] of [FormFieldState] of the invalid field(s) only, if any.
  ///
  /// This method can be useful to highlight field(s) with errors.
  ///
  /// The form will rebuild to report the results.
  ///
  /// See also:
  ///  * [validate], which also validates descendant [FormField]s,
  /// and return true if there are no errors.
  Set<FormFieldState<Object?>> validateGranularly() => _form.validateGranularly();
}
