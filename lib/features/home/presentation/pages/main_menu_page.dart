import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:impulse/core/theme/app_theme.dart';
import 'package:impulse/features/ticket/presentation/pages/favorites_ticket_page.dart';
import 'package:impulse/features/settings/presentation/pages/settings_page.dart';
import 'package:impulse/features/feedback/presentation/pages/feedback_page.dart';
import 'package:impulse/features/themes/presentation/pages/theme_list_page.dart';
import 'package:impulse/features/ticket/presentation/pages/errors_ticket_page.dart';
import 'package:impulse/features/ticket/presentation/pages/random_ticket_page.dart';
import 'package:impulse/features/home/widgets/progress_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/local_storage.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../profile/pages/profile_page.dart';
import '../../../search/search_result_page.dart';
import '../../../welcome/presentation/pages/welcome_page.dart';

class MainMenuPage extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;

  const MainMenuPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 800;
    final crossAxisCount = isDesktop ? 6 : (isTablet ? 3 : 2);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Шапка с поиском и профилем
          SliverAppBar(
            automaticallyImplyLeading: false,
            forceElevated: true, // here
            elevation: 20, // question having 0 here
            pinned: false,
            floating: true,
            snap: true,
            expandedHeight: isDesktop ? 100 : 80,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: isDesktop ? 120 : 16,
                  right: isDesktop ? 120 : 16,
                  bottom: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final searchPadding = isDesktop ? 24.0 : 16.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Поиск (занимает все доступное пространство)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: searchPadding),
                            child: SearchBar(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              hintText: 'Пошук питань...',
                              leading: Icon(
                                Icons.search,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _searchQuestions(
                                    context: context,
                                    query: value,
                                  );
                                }
                              },
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(
                                colorScheme.surfaceVariant,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(36),
                                ),
                              ),
                              constraints: BoxConstraints(
                                minHeight: 48,
                                maxHeight: 48,
                                minWidth:
                                    maxWidth * 0.6, // Минимальная ширина поиска
                              ),
                            ),
                          ),
                        ),

                        // Аватарка (фиксированный размер)
                        _buildUserAvatar(context),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 100 : (isTablet ? 40 : 10),
              vertical: 20,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Прогресс обучения
                ProgressWidget(userId: widget.userId),
                const SizedBox(height: 32),

                // Режимы обучения
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Режими навчання',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.book,
                      title: 'Теми',
                      subtitle: 'Навчання по розділах',
                      color: Colors.blue,
                      onTap:
                          () => _navigateTo(
                            context,
                            ThemeListPage(telegramUserId: widget.userId),
                          ),
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.help_outline,
                      title: 'Білет',
                      subtitle: '20 випадкових питань',
                      color: Colors.green,
                      onTap:
                          () => _navigateTo(
                            context,
                            RandomTicketPage(
                              userId: widget.userId,
                              onProgressUpdated: () {},
                            ),
                          ),
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.timer,
                      title: 'Екзамен',
                      subtitle: 'Тестування на час',
                      color: Colors.orange,
                      onTap:
                          () => _navigateTo(
                            context,
                            RandomTicketPage(
                              userId: widget.userId,
                              onProgressUpdated: () {},
                            ),
                          ),
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.error_outline,
                      title: 'Помилки',
                      subtitle: 'Робота над помилками',
                      color: Colors.red,
                      onTap:
                          () => _navigateTo(
                            context,
                            ErrorsTicketPage(
                              userId: widget.userId!,
                              onProgressUpdated: () {},
                            ),
                          ),
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.star,
                      title: 'Обране',
                      subtitle: 'Збережені питання',
                      color: Colors.purple,
                      onTap:
                          () => _navigateTo(
                            context,
                            FavoritesTicketPage(userId: widget.userId!, onProgressUpdated: (){},),
                          ),
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.lightbulb,
                      title: 'Часті помилки',
                      subtitle: 'Топ складних питань',
                      color: Colors.teal,
                      onTap:
                          () => () {
                            // _navigateTo(
                            //   context,
                            //   CommonMistakesPage(userId: widget.userId),
                            // );
                          },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Дополнительные функции
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Інші можливості',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  childAspectRatio: isDesktop ? 3 : 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Моя статистика',
                      description: 'Детальний аналіз вашого прогресу',
                      color: colorScheme.primary,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.feedback,
                      title: 'Залишити відгук',
                      description: 'Поділіться своїми враженнями',
                      color: Colors.teal,
                      onTap:
                          () => _navigateTo(
                            context,
                            FeedbackPage(userId: widget.userId),
                          ),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.settings,
                      title: 'Налаштування',
                      description: 'Персоналізація додатку',
                      color: colorScheme.secondary,
                      onTap:
                          () => _showProfileMenu(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Новости/обновления
                _buildUpdatesCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Вынесенный в отдельный метод виджет аватарки
  Widget _buildUserAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceVariant,
        ),
        child: Center(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            child:
                widget.userEmail != null
                    ? Text(
                      widget.userEmail!.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    )
                    : Icon(Icons.person, color: colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.new_releases,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Останні оновлення',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Наразі сайт знаходиться на стадії розробки, але вже зараз ви можете вчити пдр безкоштовно (версія 0.7)',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _searchQuestions({required BuildContext context, required String query}) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          query: query,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Перетаскиваемая ручка
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Заголовок и аватар
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child:
                          widget.userEmail != null
                              ? Text(
                                widget.userEmail!.substring(0, 1).toUpperCase(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                              : Icon(
                                Icons.person,
                                color: theme.colorScheme.primary,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName ?? 'Користувач',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            widget.userEmail ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Настройки темы
                _buildSettingItem(
                  context,
                  icon: Icons.brightness_6,
                  title: 'Темна тема',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) async {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Divider(height: 1),

                // Обнулить прогресс
                _buildSettingItem(
                  context,
                  icon: Icons.restart_alt,
                  title: 'Обнулити прогрес',
                  onTap: () => _confirmResetProgress(context),
                ),
                const Divider(height: 1),

                // Подписка
                _buildSettingItem(
                  context,
                  icon: Icons.workspace_premium,
                  title: 'Підписка',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Без підписки',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Функція підписки в розробці'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),

                // Выход
                _buildSettingItem(
                  context,
                  icon: Icons.exit_to_app,
                  title: 'Вийти з акаунта',
                  textColor: theme.colorScheme.error,
                  iconColor: theme.colorScheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLogout(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurface),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 24,
    );
  }

  Future<void> _confirmResetProgress(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Обнулити прогрес?'),
            content: const Text(
              'Ви впевнені, що хочете видалити всю свою статистику?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Обнулити'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      Navigator.pop(context); // Закрываем bottom sheet
      // Реализация обнуления прогреса
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Прогрес успішно обнулено')));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Вийти з акаунта?'),
            content: const Text('Ви впевнені, що хочете вийти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomePage()),
                      );
                      return true;
                    } catch (e) {
                      debugPrint('Sign out error: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Помилка виходу: ${e.toString()}'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                },
                child: const Text('Вийти'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Реализация выхода
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }
}
