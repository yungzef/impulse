import 'package:flutter/material.dart';

import '../local_storage.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = LocalStorage.getTheme();

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    LocalStorage.setTheme(mode);
    notifyListeners();
  }
}