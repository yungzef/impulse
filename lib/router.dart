// lib/router.dart
import 'package:flutter/material.dart';
import 'package:impulse/features/favorites/ui/favorites_page.dart';
import 'package:impulse/features/home/ui/main_menu_page.dart';
import 'package:impulse/features/themes/ui/theme_list_page.dart';
import 'package:impulse/features/ticket/ui/errors_ticket_page.dart';
import 'package:impulse/features/ticket/ui/random_ticket_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings, {
        String? telegramInitData,
      }) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case '/themes':
        return MaterialPageRoute(builder: (_) => const ThemeListPage());
      case '/random-ticket':
        return MaterialPageRoute(builder: (_) => const RandomTicketPage());
      case '/errors':
        return MaterialPageRoute(builder: (_) => const ErrorsTicketPage());
      case '/favorites':
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут не найден: ${settings.name}')),
          ),
        );
    }
  }
}