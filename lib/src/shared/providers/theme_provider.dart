import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  light,
  dark,
  system,
  sea,
}

final themeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.dark);

extension AppThemeModeExtension on AppThemeMode {
  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.sea:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
