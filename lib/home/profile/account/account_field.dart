import 'package:thc/the_good_stuff.dart';

/// A [TextField] with a name that matches a [ThcUser.json] key.
enum AccountField with EnumStatefulWidgetMixin {
  /// The user's first & last name (cannot be deleted).
  name,

  /// The user's email.
  ///
  /// (Eventually, we should probably verify the email whenever it's updated.)
  email;

  /// The current values in the [TextField]s.
  static final List<String> textValues = List.filled(values.length, '');
  void update(String newText) => textValues[index] = newText.trim();

  /// The value of this field before any editing occurred.
  String? get current => switch (this) {
        name => user.name,
        email => user.email,
      };

  /// The new [TextField] value that the user typed in.
  ///
  /// Set to `null` if it's empty or if it's unchanged.
  String? get updated {
    final String text = textValues[index];
    return text.isNotEmpty && text != current ? text : null;
  }

  /// A [ThcUser] object, updated to match the current [TextField] content.
  static ThcUser get updatedUser => user.copyWith(
        name: name.updated,
        email: email.updated,
      );

  /// Changes all [textValues] to match the current [user].
  static void reset() {
    for (final value in values) {
      value.update(value.current ?? '');
    }
  }

  @override
  State<AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<AccountField> {
  /// If this value is `true` (and the relevant value is non-null),
  /// a button will appear to remove (i.e. "yeet") the stored email or phone number.
  bool showYeetButton = false;
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.current);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ThcColors.of(context);

    final style = WidgetStateTextStyle.resolveWith((states) => TextStyle(
          color: colors.onSurface.withOpacity(states.isFocused ? 1.0 : 0.5),
        ));
    final decoration = InputDecoration(
      isDense: true,
      labelText: widget.name,
      labelStyle: style,
      floatingLabelStyle: style,
      border: MaterialStateOutlineInputBorder.resolveWith((states) {
        return OutlineInputBorder(
          borderSide: states.isFocused
              ? BorderSide(color: colors.primary, width: 2)
              : BorderSide(color: colors.onSurface.withOpacity(0.5)),
        );
      }),
    );

    final Widget yeetButton;
    if (showYeetButton && (widget.current?.isNotEmpty ?? false)) {
      yeetButton = TextButton(
        onPressed: () async {
          await context.read<AccountFields>().yeet(widget);
          setState(() => widget.update(''));
        },
        style: TextButton.styleFrom(foregroundColor: colors.error),
        child: const Text('remove'),
      );
    } else {
      yeetButton = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: decoration,
              onChanged: (newText) {
                setState(() => showYeetButton = newText.isEmpty);
                context.read<AccountFields>().update(widget..update(newText));
              },
            ),
          ),
          AnimatedSize(
            duration: Durations.medium1,
            curve: Curves.ease,
            child: yeetButton,
          ),
        ],
      ),
    );
  }
}

class AccountFields extends Cubit<ThcUser?> {
  AccountFields() : super(user);

  void update(AccountField field) => value = AccountField.updatedUser;

  bool get hasChanges => AccountField.values.any((value) => value.updated != null);

  Future<void> save(ThcUser updatedUser) async {
    await updatedUser.upload();
    value = user = updatedUser;
  }

  Future<void> yeet(AccountField field) async {
    final Json data = user.json..remove(field.name);
    await save(ThcUser.fromJson(data));
  }
}
