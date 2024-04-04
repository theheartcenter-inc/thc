import 'package:flutter/services.dart';
import 'package:thc/utils/navigator.dart';

bool shortcuts(KeyEvent event) {
  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
    navigator.pop();
    return true;
  }
  return false;
}
