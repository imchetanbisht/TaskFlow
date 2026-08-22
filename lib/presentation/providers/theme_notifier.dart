import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  static const String _themeKey = 'app_theme_mode';

  ThemeNotifier(this._ref) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final storage = _ref.read(localStorageServiceProvider);
      final val = storage.getString(_themeKey);
      if (val == 'dark') {
        state = ThemeMode.dark;
      } else if (val == 'system') {
        state = ThemeMode.system;
      } else {
        state = ThemeMode.light;
      }
    } catch (_) {
      state = ThemeMode.light;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final storage = _ref.read(localStorageServiceProvider);
      final val = mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light';
      await storage.setString(_themeKey, val);
    } catch (_) {}
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref);
});
