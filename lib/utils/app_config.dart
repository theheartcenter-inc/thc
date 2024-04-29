import 'package:flutter/foundation.dart';

/// Use `if (mobileDevice)` when you want different behavior
/// based on whether a touchscreen or mouse cursor is being used.
final mobileDevice = switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.iOS => true,
  _ => false,
};

/// Set this to `false` if you're just working on frontend stuff
/// and you don't want to worry about connecting with Agora or Firebase.
const useInternet = true;

/// If set to `true`, we expect everything to run perfectly and will throw errors
/// when stuff goes wrong.
const superStrict = false;

class ErrorIfStrict extends Error {
  ErrorIfStrict(this.message) {
    if (superStrict) throw this;
  }

  final dynamic message;

  @override
  String toString() => 'Error: $message';
}

/// Set this to `true` to print to the console each time we connect with Firebase.
const backendPrints = true;

void backendPrint(dynamic message) {
  if (backendPrints) if (kDebugMode) print(message);
}
