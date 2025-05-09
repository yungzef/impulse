// lib/features/home/ui/main_menu_page.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:impulse/features/home/widgets/progress_widget.dart';
import 'package:impulse/features/themes/ui/theme_list_page.dart';
import '../../favorites/ui/favorites_page.dart';
import '../../ticket/ui/errors_ticket_page.dart';
import '../../ticket/ui/random_ticket_page.dart';

class MainMenuPage extends StatelessWidget {
  final String? userId;

  const MainMenuPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное меню'),
        actions: [
          IconButton(
            icon: Icon(Icons.palette),
            onPressed: () {
              // TODO: Реализовать смену темы
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProgressWidget(userId: userId),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              childAspectRatio: 1.1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuButton(
                  context,
                  icon: Icons.book,
                  label: 'Темы',
                  color: Color(0xFF4361EE),
                  onTap:
                      () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ThemeListPage(telegramUserId: userId),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                        ),
                      ),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.help_outline,
                  label: 'Билет',
                  color: Color(0xFF3F37C9),
                  onTap:
                      () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  RandomTicketPage(
                                    telegramUserId: userId,
                                    onProgressUpdated: () {
                                    },
                                  ),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                        ),
                      ),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.error_outline,
                  label: 'Ошибки',
                  color: Color(0xFFF72585),
                  onTap:
                      () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ErrorsTicketPage(
                                    userId: userId,
                                    onProgressUpdated: () {
                                    },
                                  ),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                        ),
                      ),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.star,
                  label: 'Избранное',
                  color: Color(0xFFF8961E),
                  onTap:
                      () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  FavoritesPage(userId: userId),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
