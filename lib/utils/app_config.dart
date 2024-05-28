import 'package:flutter/foundation.dart';

/// Use `if (mobileDevice)` when you want different behavior
/// based on whether a touchscreen or mouse cursor is being used.
final mobileDevice = switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.iOS => true,
  _ => false,
};

/// Use `if (appleDevice)` when you want stuff to look differently
/// on iOS/MacOS.
final appleDevice = switch (defaultTargetPlatform) {
  TargetPlatform.iOS || TargetPlatform.macOS => true,
  _ => false,
};

/// Set this to `true` to print to the console each time we connect with Firebase.
const backendPrints = false;

void backendPrint(dynamic message) {
  if (backendPrints) if (kDebugMode) print(message);
}
