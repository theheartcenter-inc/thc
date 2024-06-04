import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  loadUser();
  runApp(const App());
}

Future<void> initFirebase() async {
  final options = switch (defaultTargetPlatform) {
    TargetPlatform() when kIsWeb => FirebaseCredentials.web,
    TargetPlatform.android => FirebaseCredentials.android,
    TargetPlatform.iOS => FirebaseCredentials.ios,
    TargetPlatform.macOS => FirebaseCredentials.macos,
    TargetPlatform.linux || TargetPlatform.windows => FirebaseCredentials.web,
    TargetPlatform.fuchsia => throw Exception("(I don't think we'll be supporting Fuchsia)"),
  };

  await Firebase.initializeApp(options: options);
}

void loadUser() {
  // Mocked loading user from local storage
  String name = 'Test User';
  String id = 'test_user_id';
  UserType type = UserType.participant;
  String? email = 'test@example.com';

  ThcUser.instance = ThcUser(name: name, type: type, id: id, email: email);

  if (id == null) return;

  try {
    ThcUser.download(id).then((user) => ThcUser.instance = user);
  } catch (e) {
    assert(false, e.toString());
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => AccountFields()),
      ],
      child: MaterialApp(
        navigatorKey: navKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: context.watch<AppTheme>().state,
        debugShowCheckedModeBanner: false,
        home: const ChooseAnyView(),
      ),
    );
  }
}

enum UserType {
  participant,
  director,
  admin;

  bool get canLivestream => switch (this) {
    participant => false,
    director || admin => true,
  };

  bool get isAdmin => this == admin;

  @override
  String toString() => switch (this) {
    participant => 'Participant',
    director => 'Director',
    admin => 'Admin',
  };
}

class ThcUser {
  final String name;
  final String? email;
  final String id;
  final UserType type;
  final String? profilePictureUrl;

  ThcUser({
    required this.name,
    this.email,
    required this.id,
    required this.type,
    this.profilePictureUrl,
  });

  static ThcUser instance = ThcUser(name: 'Guest', id: 'guest', type: UserType.participant);

  factory ThcUser.fromJson(Map<String, dynamic> json) {
    return ThcUser(
      name: json['name'] as String,
      email: json['email'] as String?,
      id: json['id'] as String,
      type: UserType.values.byName(json['type']),
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'id': id,
      'type': type.name,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  Future<void> upload() async {
    await FirebaseFirestore.instance.collection('users').doc(id).set(toJson());
  }

  static Future<ThcUser> download(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return ThcUser.fromJson(doc.data()!);
  }

  ThcUser copyWith({
    String? name,
    String? email,
    String? id,
    UserType? type,
    String? profilePictureUrl,
  }) {
    return ThcUser(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      type: type ?? this.type,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}

class AccountFields extends ChangeNotifier {
  ThcUser? value = ThcUser.instance;

  void update(AccountField field) {
    value = AccountField.updatedUser;
    notifyListeners();
  }

  bool get hasChanges => AccountField.values.any((value) => value.updated != null);

  Future<void> save(ThcUser updatedUser) async {
    await updatedUser.upload();
    value = ThcUser.instance = updatedUser;
    notifyListeners();
  }

  Future<void> yeet(AccountField field) async {
    final data = ThcUser.instance.toJson()..remove(field.name);
    await save(ThcUser.fromJson(data));
  }
}

enum AccountField with StatefulEnum {
  name,
  email;

  static final List<String> textValues = List.filled(values.length, '');
  void update(String newText) => textValues[index] = newText.trim();

  String? get current => switch (this) {
    name => ThcUser.instance.name,
    email => ThcUser.instance.email,
  };

  String? get updated {
    final text = textValues[index];
    return text.isNotEmpty && text != current ? text : null;
  }

  static ThcUser get updatedUser => ThcUser.instance.copyWith(
    name: name.updated,
    email: email.updated,
  );

  static void reset() {
    for (final value in values) {
      value.update(value.current ?? '');
    }
  }

  @override
  State<AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<AccountField> {
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
    final colors = ThcColors.of(context);

    final style = WidgetStateTextStyle.resolveWith((states) => StyleText(
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

class ProfilePictureUploader extends StatefulWidget {
  final ThcUser user;

  const ProfilePictureUploader({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePictureUploaderState createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  final ImagePicker _picker = ImagePicker();
  String? _uploadedFileURL;

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${widget.user.id}');
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          _uploadedFileURL = downloadUrl;
        });
        final updatedUser = widget.user.copyWith(profilePictureUrl: downloadUrl);
        await context.read<AccountFields>().save(updatedUser);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_uploadedFileURL != null)
          Image.network(_uploadedFileURL!, width: 100, height: 100)
        else if (widget.user.profilePictureUrl != null)
          Image.network(widget.user.profilePictureUrl!, width: 100, height: 100)
        else
          const PlaceholderImage(width: 100),
        ElevatedButton(
          onPressed: _pickAndUploadImage,
          child: const Text('Upload Profile Picture'),
        ),
      ],
    );
  }
}

enum ProfileOption with StatelessEnum {
  account(
    Icons.person_rounded,
    action: AccountSettings(),
  ),

  settings(
    Icons.settings,
    action: SettingsScreen(),
  ),

  info(
    Icons.info_outline,
    label: 'about The Heart Center',
    action: HeartCenterInfo(),
  ),

  donate(
    Icons.favorite,
    action: HeartCenterInfo.donate,
  ),

  report(
    Icons.report_problem,
    label: 'report an issue / send feedback',
    action: IssueReport(),
  ),

  chooseAnyView(
    Icons.build,
    label: 'choose any view',
    action: ChooseAnyView(),
  );

  const ProfileOption(this.icon, {this.label, required this.action});
  final IconData icon;
  final String? label;

  /// Determines the behavior of `onTap()` in the [build] method below.
  final dynamic action;

  static final count = values.length + (kDebugMode ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(left: 16);

    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Padding(padding: padding, child: Text(label ?? name)),
      trailing: const Icon(Icons.chevron_right),
      onTap: switch (action) {
        VoidCallback() => action,
        Widget() => () => navigator.push(action),
        _ => throw TypeError(),
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userWatch = context.watch<AccountFields>().value ?? ThcUser(name: 'Not Found', id: '');
    assert(userWatch.name != 'Not Found', "couldn't get AccountFields data");

    final linkColor = Color.lerp(ThcColors.dullBlue, ThcColors.teal, 0.25)!;
    final overview = DefaultTextStyle(
      style: StyleText(height: 1.75, color: ThcColors.of(context).onSurface),
      child: Center(
        child: Column(
          children: [
            ProfilePictureUploader(user: userWatch),
            Text(userWatch.name, style: const StyleText(size: 28)),
            if (userWatch.id != null) Text('user ID: ${userWatch.id}', style: const StyleText(weight: 600)),
            if (userWatch.email != null)
              Text(userWatch.email!, style: StyleText(color: linkColor)),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );

    return ProfileListView(
      itemCount: ProfileOption.count,
      itemBuilder: (_, index) => switch (index - 1) {
        -1 => overview,
        final i => ProfileOption.values[i],
      },
    );
  }
}

class ProfileListView extends StatelessWidget {
  const ProfileListView({required this.itemCount, required this.itemBuilder, super.key});
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              separatorBuilder: (_, __) => const Divider(),
            ),
          ),
        ),
      ),
    );
  }
}

// Addi- classes and enums to resolve dependencies
class AppTheme extends ChangeNotifier {
  ThemeMode state = ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Account Settings')));
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Settings Screen')));
  }
}

class HeartCenterInfo extends StatelessWidget {
  static const Widget donate = Text('Donate');

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Heart Center Info')));
  }
}

class IssueReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Issue Report')));
  }
}

class ChooseAnyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Choose Any View')));
  }
}

class PlaceholderImage extends StatelessWidget {
  final double width;
  const PlaceholderImage({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      color: Colors.grey,
      child: Icon(Icons.image, size: width / 2),
    );
  }
}

class ThcColors {
  static Color dullBlue = Colors.blueGrey;
  static Color teal = Colors.teal;

  static ThcColors of(BuildContext context) => ThcColors();

  Color get onSurface => Colors.black;
  Color get primary => Colors.blue;
}

class StyleText extends TextStyle {
  const StyleText({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = Colors.black,
    double height = 1.0,
  }) : super(fontSize: size, fontWeight: weight, color: color, height: height);
}

class WidgetStateTextStyle {
  static TextStyle resolveWith(TextStyle Function(Set<MaterialState> states) callback) {
    return callback({MaterialState.focused});
  }
}

class MaterialStateOutlineInputBorder {
  static OutlineInputBorder resolveWith(OutlineInputBorder Function(Set<MaterialState> states) callback) {
    return callback({MaterialState.focused});
  }
}

class Durations {
  static Duration medium1 = Duration(milliseconds: 300);
}

class NavigatorKey {
  static GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
}

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

