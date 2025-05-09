import 'package:flutter/material.dart';
import 'package:impulse/features/home/ui/main_menu_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings, {
        String? telegramInitData,
        String? telegramUserId, // Единое именование параметра
      }) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => MainMenuPage(
            userId: telegramUserId, // Правильное имя параметра
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}