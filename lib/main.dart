import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:impulse/core/theme/app_theme.dart';
import 'package:impulse/features/welcome/presentation/pages/welcome_page.dart';

import 'core/injection.dart';

void main() async {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies(); // Добавить эту строку
  runApp(const ImpulseApp());
}

class ImpulseApp extends StatelessWidget {
  const ImpulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Светлая тема
      darkTheme: AppTheme.darkTheme, // Тёмная тема
      themeMode: ThemeMode.light, // Явно устанавливаем светлую тему
      home: const WelcomePage(),
    );
  }
}