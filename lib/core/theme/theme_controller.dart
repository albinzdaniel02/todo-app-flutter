import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  static const String _settingsBoxName = 'settings';
  static const String _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    try {
      if (Hive.isBoxOpen(_settingsBoxName)) {
        final box = Hive.box(_settingsBoxName);
        final themeString =
            box.get(_themeModeKey, defaultValue: 'system') as String;
        return _parseThemeMode(themeString);
      }
    } catch (_) {
      // Graceful fallback for non-initialized state (e.g., during tests)
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final box = Hive.isBoxOpen(_settingsBoxName)
          ? Hive.box(_settingsBoxName)
          : await Hive.openBox(_settingsBoxName);
      await box.put(_themeModeKey, mode.name);
    } catch (_) {
      // Graceful fallback for non-initialized state (e.g., during tests)
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode _parseThemeMode(String value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
