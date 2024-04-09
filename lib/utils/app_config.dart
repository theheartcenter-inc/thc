import 'dart:io';

/// Use `if (mobileDevice)` when you want different behavior
/// based on whether a touchscreen or mouse cursor is being used.
final mobileDevice = switch (Platform.operatingSystem) { 'ios' || 'android' => true, _ => false };

/// Set this to `false` if you're just working on frontend stuff
/// and you don't want to worry about connecting with Agora or Firebase.
const useInternet = true;
