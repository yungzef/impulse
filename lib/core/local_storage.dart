import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class LocalStorage {
  static const String _key = 'theme_mode';

  static Future<void> setTheme(ThemeMode mode) async {
    html.window.localStorage[_key] = mode.toString().split('.').last;
  }

  static ThemeMode getTheme() {
    final value = html.window.localStorage[_key];
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}