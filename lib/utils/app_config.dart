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

/// Controls whether the "choose any view" option is shown.
const production = false;
