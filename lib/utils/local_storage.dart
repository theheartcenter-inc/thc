import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';

late final SharedPreferences _storage;

Future<void> loadFromLocalStorage() async {
  _storage = await SharedPreferences.getInstance();
  // await _storage.clear();
}

Future<dynamic> resetLocalStorage([UserType? userType]) async {
  final ThemeMode keepTheThemeOfCourse = LocalStorage.themeMode();
  await _storage.clear();
  await LocalStorage.themeMode.save(keepTheThemeOfCourse.index);

  if (userType == null) return user = null;

  await Future.wait([
    for (final MapEntry(key: storageKey, :value) in userType.testUserSaveData.entries)
      storageKey.save(value),
    ThcUser.download(userType.testId).then((value) => user = value),
  ]);
}

/// {@template StorageKeys}
/// Local storage supports 5 types:
/// ```dart
/// bool, int, double, String, List<String>
/// ```
/// Other types need to be converted in order to save/load.
/// {@endtemplate}
enum LocalStorage {
  loggedIn,
  userId,
  userType,
  email,
  password,
  firstLastName,
  themeMode,
  navBarSelection,
  adminWatchLive,
  adminStream,
  notify;

  /// {@macro StorageKeys}
  dynamic get initial => switch (this) {
        loggedIn => false,
        userId || userType || email => null,
        password || firstLastName => '',
        themeMode => ThemeMode.system.index,
        navBarSelection => 0,
        adminWatchLive || adminStream => false,
        notify => null
      };

  /// {@macro StorageKeys}
  dynamic get fromStorage => _storage.get(name) ?? initial;

  /// By defining the `call()` method of a class, you're able
  /// to call the class instance as if it were a function.
  ///
  /// This has the advantage of looking really snazzy.
  dynamic call() {
    final value = fromStorage;
    if (value == 'null') return null;
    return switch (this) {
      loggedIn || userId || email || password || firstLastName => value,
      userType when value == null => null,
      userType => UserType.values[value],
      themeMode => ThemeMode.values[value],
      navBarSelection => NavBarButton.values[value],
      adminWatchLive || adminStream => value,
      notify => value
    };
  }

  /// {@macro StorageKeys}
  Future<bool> save(dynamic newValue) => switch (newValue) {
        null => _storage.setString(name, 'null'),
        bool() => _storage.setBool(name, newValue),
        int() => _storage.setInt(name, newValue),
        double() => _storage.setDouble(name, newValue),
        String() => _storage.setString(name, newValue),
        List<String>() => _storage.setStringList(name, newValue),
        _ => throw TypeError(),
      };
}
