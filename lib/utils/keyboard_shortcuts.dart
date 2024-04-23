import 'package:flutter/services.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';

void addKeyboardShortcuts() {
  HardwareKeyboard.instance.addHandler((event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (LocalStorage.loggedIn()) {
        navigator.pop();
      } else {
        LoginProgressTracker.pop();
      }
      return true;
    }
    return false;
  });
}
