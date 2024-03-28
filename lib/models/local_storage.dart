import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/home/home_screen.dart';

Future<void> loadFromLocalStorage() async {
  _storage = await SharedPreferences.getInstance();
}

late final SharedPreferences _storage;

/// {@template models.local_storage.StorageKeys}
/// Local storage supports 5 types:
/// ```dart
/// bool, int, double, String, List<String>
/// ```
/// Other types need to be converted in order to save/load.
/// {@endtemplate}
enum StorageKeys {
  themeMode,
  userType,
  navBarState,
  adminWatchLive,
  adminStream,
  ;

  /// {@macro models.local_storage.StorageKeys}
  dynamic get initial => switch (this) {
        themeMode => ThemeMode.system.index,
        userType => UserType.participant.index,
        navBarState => 0,
        adminWatchLive => true,
        adminStream => false,
      };

  /// {@macro models.local_storage.StorageKeys}
  dynamic get fromStorage => _storage.get(name) ?? initial;

  /// By defining the `call()` method of a class, you're able
  /// to call the class instance as if it were a function.
  ///
  /// This has the advantage of looking really snazzy.
  dynamic call() => switch (this) {
        themeMode => ThemeMode.values[fromStorage],
        userType => UserType.values[fromStorage],
        navBarState => NavBarButton.values[fromStorage],
        adminWatchLive || adminStream => fromStorage,
      };

  /// {@macro models.local_storage.StorageKeys}
  Future<bool> save(dynamic newValue) => switch (newValue) {
        bool() => _storage.setBool(name, newValue),
        int() => _storage.setInt(name, newValue),
        double() => _storage.setDouble(name, newValue),
        String() => _storage.setString(name, newValue),
        List<String>() => _storage.setStringList(name, newValue),
        _ => throw TypeError(),
      };
}
