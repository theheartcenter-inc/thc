import 'dart:io';

/// Use `if (mobileDevice)` when you want different behavior
/// based on whether a touchscreen or mouse cursor is being used.
final mobileDevice = switch (Platform.operatingSystem) { 'ios' || 'android' => true, _ => false };
