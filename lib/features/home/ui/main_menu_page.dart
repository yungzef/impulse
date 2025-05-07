// 📁 lib/features/home/ui/main_menu_page.dart

import 'package:flutter/material.dart';
import 'package:impulse/features/home/widgets/progress_widget.dart';
import 'package:impulse/features/themes/ui/theme_list_page.dart';

import '../../favorites/ui/favorites_page.dart';
import '../../ticket/ui/errors_ticket_page.dart';
import '../../ticket/ui/random_ticket_page.dart';

// lib/features/home/ui/main_menu_page.dart
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Меню')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ProgressWidget(),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _MenuButton(
                  label: 'Темы',
                  icon: Icons.book,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ThemeListPage()),
                    );
                  },
                ),
                _MenuButton(
                  label: 'Билет',
                  icon: Icons.confirmation_number,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RandomTicketPage()),
                    );
                  },
                ),
                _MenuButton(
                  label: 'Ошибки',
                  icon: Icons.error,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorsTicketPage()),
                    );
                  },
                ),
                _MenuButton(
                  label: 'Избранные',
                  icon: Icons.star,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Перенесен внутрь класса MainMenuPage как приватный виджет
class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}