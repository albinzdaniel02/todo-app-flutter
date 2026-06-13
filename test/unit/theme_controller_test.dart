import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/core/theme/theme_controller.dart';

void main() {
  group('ThemeController Tests', () {
    late Directory tempDir;
    late Box settingsBox;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('theme_controller_test');
      Hive.init(tempDir.path);
      settingsBox = await Hive.openBox('settings');
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await settingsBox.close();
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initial state should be ThemeMode.system when no theme is saved', () {
      final themeMode = container.read(themeControllerProvider);
      expect(themeMode, equals(ThemeMode.system));
    });

    test(
      'setThemeMode should update theme mode state and save to Hive',
      () async {
        final controller = container.read(themeControllerProvider.notifier);

        await controller.setThemeMode(ThemeMode.dark);
        expect(container.read(themeControllerProvider), equals(ThemeMode.dark));
        expect(settingsBox.get('theme_mode'), equals('dark'));

        await controller.setThemeMode(ThemeMode.light);
        expect(
          container.read(themeControllerProvider),
          equals(ThemeMode.light),
        );
        expect(settingsBox.get('theme_mode'), equals('light'));
      },
    );

    test(
      'toggleTheme should switch theme mode state and save to Hive',
      () async {
        final controller = container.read(themeControllerProvider.notifier);

        await controller.toggleTheme(true);
        expect(container.read(themeControllerProvider), equals(ThemeMode.dark));
        expect(settingsBox.get('theme_mode'), equals('dark'));

        await controller.toggleTheme(false);
        expect(
          container.read(themeControllerProvider),
          equals(ThemeMode.light),
        );
        expect(settingsBox.get('theme_mode'), equals('light'));
      },
    );
  });
}
