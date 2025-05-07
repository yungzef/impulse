// lib/main.dart
import 'package:flutter/material.dart';
import 'package:impulse/router.dart';
import 'package:impulse/core/services/api_client.dart';

void main() {
  runApp(const ImpulseApp());
}

class ImpulseApp extends StatefulWidget {
  const ImpulseApp({super.key});

  @override
  State<ImpulseApp> createState() => _ImpulseAppState();
}

class _ImpulseAppState extends State<ImpulseApp> {
  String? _telegramInitData;

  @override
  void initState() {
    super.initState();
    _initTelegram();
  }

  Future<void> _initTelegram() async {
    try {
      // Для веб-версии (если нужно)
      if (isWeb()) {
        _telegramInitData = await _getTelegramWebAppData();
      }
      // Для мобильных версий можно добавить другую логику
    } catch (e) {
      debugPrint('Error initializing Telegram: $e');
    }
  }

  // Заглушка для веб-версии
  Future<String?> _getTelegramWebAppData() async {
    // Здесь должна быть реализация получения данных из Telegram WebApp
    // В реальном приложении это будет JavaScript-код
    return null;
  }

  // Проверка платформы
  bool isWeb() {
    return identical(0, 0.0); // Упрощенная проверка для примера
    // Лучше использовать package:flutter/foundation.dart и kIsWeb
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      onGenerateRoute: (settings) => AppRouter.generateRoute(
        settings,
        telegramInitData: _telegramInitData,
      ),
    );
  }
}