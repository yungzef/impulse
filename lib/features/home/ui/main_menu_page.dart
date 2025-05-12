// Файл: main_menu_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/features/home/widgets/progress_widget.dart';
import 'package:impulse/features/settings/ui/settings_page.dart';
import 'package:impulse/features/feedback/ui/feedback_page.dart';
import 'package:impulse/features/themes/ui/theme_list_page.dart';
import 'package:impulse/features/ticket/ui/errors_ticket_page.dart';
import 'package:impulse/features/ticket/ui/random_ticket_page.dart';
import 'package:impulse/features/favorites/ui/favorites_page.dart';

class MainMenuPage extends StatelessWidget {
  final String? userId;

  const MainMenuPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final crossAxisCount = isDesktop ? 4 : 2;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // appBar: AppBar(
      //   title: Text(
      //     'IMPULSE',
      //     style: TextStyle(
      //       fontWeight: FontWeight.w800,
      //       letterSpacing: 1.2,
      //       color: colorScheme.onBackground,
      //     ),
      //   ),
      //   backgroundColor: colorScheme.surface,
      //   elevation: 0,
      //   actions: isDesktop
      //       ? [
      //     _buildNavItem('О платформе', context),
      //     _buildNavItem('Как работает', context),
      //     _buildNavItem('Отзывы', context),
      //     _buildNavItem('Контакты', context),
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 16),
      //       child: ElevatedButton(
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: colorScheme.primary,
      //           foregroundColor: colorScheme.onPrimary,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(24),
      //           ),
      //         ),
      //         onPressed: () {},
      //         child: const Text('Начать тест'),
      //       ),
      //     )
      //   ]
      //       : [
      //     IconButton(
      //       icon: Icon(Icons.menu, color: colorScheme.onSurface),
      //       onPressed: () => Scaffold.of(context).openDrawer(),
      //     ),
      //   ],
      // ),
      drawer: isDesktop ? null : _buildMobileDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            // Container(
            //   padding: EdgeInsets.symmetric(
            //     vertical: isDesktop ? 120 : 60,
            //     horizontal: isDesktop ? 120 : 24,
            //   ),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [
            //         colorScheme.surface,
            //         colorScheme.background,
            //       ],
            //     ),
            //   ),
            //   child: Column(
            //     children: [
            //       Text(
            //         'Готуйтеся до іспиту з ПДР\n з офіційними тестами МВС',
            //         style: TextStyle(
            //           color: colorScheme.onBackground,
            //           fontSize: isDesktop ? 48 : 32,
            //           fontWeight: FontWeight.w700,
            //           height: 1.2,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //       const SizedBox(height: 24),
            //       Text(
            //         'Швидко, зручно, зі штучним інтелектом',
            //         style: TextStyle(
            //           color: colorScheme.onSurface.withOpacity(0.7),
            //           fontSize: isDesktop ? 24 : 18,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //       const SizedBox(height: 40),
            //       ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: colorScheme.primary,
            //           foregroundColor: colorScheme.onPrimary,
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 48,
            //             vertical: 20,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(24),
            //           ),
            //           textStyle: const TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //         onPressed: () {},
            //         child: const Text('Почати підготовку'),
            //       ),
            //       if (isDesktop) ...[
            //         const SizedBox(height: 80),
            //         Image.asset(
            //           'assets/images/phone_mockup.png',
            //           height: 500,
            //         ),
            //       ],
            //     ],
            //   ),
            // ),

            // Features Section
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 80),
            //   decoration: BoxDecoration(
            //     color: colorScheme.surfaceVariant,
            //     borderRadius: BorderRadius.circular(32),
            //   ),
            //   margin: EdgeInsets.symmetric(
            //     horizontal: isDesktop ? 120 : 24,
            //     vertical: 24,
            //   ),
            //   child: Column(
            //     children: [
            //       Text(
            //         'Чому обирають Impulse',
            //         style: TextStyle(
            //           color: colorScheme.onBackground,
            //           fontSize: isDesktop ? 36 : 28,
            //           fontWeight: FontWeight.w700,
            //         ),
            //       ),
            //       const SizedBox(height: 60),
            //       GridView.count(
            //         shrinkWrap: true,
            //         physics: const NeverScrollableScrollPhysics(),
            //         crossAxisCount: isDesktop ? 4 : 2,
            //         childAspectRatio: 0.8,
            //         mainAxisSpacing: 24,
            //         crossAxisSpacing: 24,
            //         padding: EdgeInsets.symmetric(
            //           horizontal: isDesktop ? 60 : 24,
            //         ),
            //         children: [
            //           _buildFeatureCard(
            //             icon: Icons.update,
            //             title: 'Актуальні тести МВС',
            //             description:
            //             'Усі питання відповідають офіційній базі МВС України',
            //             colorScheme: colorScheme,
            //           ),
            //           _buildFeatureCard(
            //             icon: Icons.flash_on,
            //             title: 'Швидка підготовка',
            //             description:
            //             'Сфокусоване навчання без зайвої інформації',
            //             colorScheme: colorScheme,
            //           ),
            //           _buildFeatureCard(
            //             icon: Icons.auto_awesome,
            //             title: 'Допомога ШІ',
            //             description:
            //             'Адаптивний режим навчання на основі вашого прогресу',
            //             colorScheme: colorScheme,
            //           ),
            //           _buildFeatureCard(
            //             icon: Icons.analytics,
            //             title: 'Статистика',
            //             description:
            //             'Детальний аналіз вашого прогресу та помилок',
            //             colorScheme: colorScheme,
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // Progress Widget
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 120 : 24, vertical: 20),
              child: ProgressWidget(userId: userId),
            ),

            // Main Functions Grid
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 120 : 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                children: [
                  _buildMainFunctionCard(
                    context,
                    icon: Icons.book,
                    label: 'Теми',
                    onTap: () => _navigateTo(
                        context, ThemeListPage(telegramUserId: userId)),
                    colorScheme: colorScheme,
                  ),
                  _buildMainFunctionCard(
                    context,
                    icon: Icons.help_outline,
                    label: 'Білет',
                    onTap: () => _navigateTo(
                        context,
                        RandomTicketPage(
                          telegramUserId: userId,
                          onProgressUpdated: () {},
                        )),
                    colorScheme: colorScheme,
                  ),
                  _buildMainFunctionCard(
                    context,
                    icon: Icons.error_outline,
                    label: 'Помилки',
                    onTap: () => _navigateTo(
                        context,
                        ErrorsTicketPage(
                          userId: userId,
                          onProgressUpdated: () {},
                        )),
                    colorScheme: colorScheme,
                  ),
                  _buildMainFunctionCard(
                    context,
                    icon: Icons.star,
                    label: 'Обране',
                    onTap: () =>
                        _navigateTo(context, FavoritesPage(userId: userId)),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),

            // // App Download Section
            // if (isDesktop) ...[
            //   Container(
            //     padding: const EdgeInsets.symmetric(vertical: 80),
            //     margin: const EdgeInsets.symmetric(vertical: 40),
            //     decoration: BoxDecoration(
            //       color: colorScheme.surfaceVariant,
            //       borderRadius: BorderRadius.circular(32),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Image.asset(
            //           'assets/images/app_screens.png',
            //           height: 400,
            //         ),
            //         const SizedBox(width: 60),
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'Тепер "Імпульс" доступний у Telegram-боті та на сайті',
            //               style: TextStyle(
            //                 color: colorScheme.onBackground,
            //                 fontSize: 32,
            //                 fontWeight: FontWeight.w700,
            //               ),
            //             ),
            //             const SizedBox(height: 24),
            //             Text(
            //               'Готуйтеся до іспиту в будь-якому місці\пі в будь-який час',
            //               style: TextStyle(
            //                 color: colorScheme.onSurface.withOpacity(0.7),
            //                 fontSize: 18,
            //               ),
            //             ),
            //             const SizedBox(height: 40),
            //             Row(
            //               children: [
            //                 Image.asset(
            //                   'assets/images/app_store.png',
            //                   height: 50,
            //                 ),
            //                 const SizedBox(width: 16),
            //                 Image.asset(
            //                   'assets/images/google_play.png',
            //                   height: 50,
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String text, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMPULSE',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userId ?? 'Гість',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.info, color: colorScheme.onSurface),
            title: Text('О платформе',
                style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.help, color: colorScheme.onSurface),
            title: Text('Как работает',
                style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.reviews, color: colorScheme.onSurface),
            title: Text('Отзывы',
                style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.contact_page, color: colorScheme.onSurface),
            title: Text('Контакты',
                style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {},
          ),
          Divider(color: colorScheme.outline),
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.onSurface),
            title: Text('Настройки',
                style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: colorScheme.onSurface),
            title: Text('Обратная связь',
                style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMainFunctionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required ColorScheme colorScheme,
      }) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}