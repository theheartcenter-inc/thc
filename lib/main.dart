import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/admin_portal/admin_portal.dart';
import 'package:thc/views/home/home_screen.dart';

void main() async {
  await loadFromLocalStorage();
  const App().run();
}

class App extends StatelessWidget {
  const App({super.key});

  void run() => runApp(ChangeNotifierProvider(create: (_) => AppTheme(), child: this));

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<AppTheme>(context).mode;

    return MaterialApp(
      navigatorKey: navKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const ChooseAnyView(),
    );
  }
}

/// {@template main.ChooseAnyView}
/// Change the value of `home` to anything you want!
///
/// If you're working on the login screen, you can use
/// ```dart
///   home: const LoginScreen(),
/// ```
/// {@endtemplate}
class ChooseAnyView extends StatelessWidget {
  /// {@macro main.ChooseAnyView}
  const ChooseAnyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Image.asset('assets/thc_logo_with_text.png', width: 250),
            const Spacer(flex: 2),
            for (final type in UserType.values) UserButton(type),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class UserButton extends StatelessWidget {
  const UserButton(this.type, {super.key});
  final UserType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final buttonStyle = switch (type) {
      UserType.participant => ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      UserType.director => ElevatedButton.styleFrom(
          backgroundColor: colors.secondary,
          foregroundColor: colors.onSecondary,
        ),
      UserType.admin => ElevatedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: () {
          userType = type;
          navigator.pushReplacement(switch (type) {
            UserType.participant => const ParticipantHomeScreen(),
            UserType.director => const DirectorHomeScreen(),
            UserType.admin => const AdminPortal(),
          });
        },
        style: buttonStyle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('view as $type', style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
