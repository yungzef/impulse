import 'package:flutter/material.dart';
import 'package:impulse/core/theme/app_theme.dart';

import '../../../core/local_storage.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userEmail;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkTheme = false;
  bool _hasSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _checkSubscription();
  }

  Future<void> _loadThemePreference() async {
    final theme = await LocalStorage.getTheme();
    setState(() {
      _isDarkTheme = theme == ThemeMode.dark;
    });
  }

  Future<void> _checkSubscription() async {
    // Здесь будет проверка подписки (пока фейковая)
    setState(() {
      _hasSubscription = false;
    });
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Обнулити прогрес?'),
        content: const Text('Ви впевнені, що хочете видалити всю свою статистику?'),
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
      // Реализация обнуления прогреса
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Прогрес успішно обнулено')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Особистий кабінет'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserInfoCard(theme),
          const SizedBox(height: 24),
          _buildSettingsSection(theme),
          const SizedBox(height: 24),
          _buildActionsSection(theme),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: widget.userEmail != null
                  ? Text(
                widget.userEmail!.substring(0, 1).toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
                  : Icon(
                Icons.person,
                size: 40,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSubscriptionStatus(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _hasSubscription
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _hasSubscription ? Icons.check_circle : Icons.error,
            size: 16,
            color: _hasSubscription ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            _hasSubscription ? 'Підписка активна' : 'Без підписки',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _hasSubscription ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Налаштування',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Світла тема'),
                value: _isDarkTheme,
                onChanged: (value) async {
                  setState(() => _isDarkTheme = value);
                  await LocalStorage.setTheme(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                  AppTheme.setTheme(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Обнулити прогрес'),
                leading: const Icon(Icons.restart_alt),
                onTap: _resetProgress,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Дії',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              if (!_hasSubscription) ...[
                ListTile(
                  title: const Text('Оформити підписку'),
                  leading: const Icon(Icons.workspace_premium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Фейковая реализация подписки
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Функція підписки в розробці')),
                    );
                  },
                ),
                const Divider(height: 1),
              ],
              ListTile(
                title: const Text('Вийти з акаунта'),
                leading: const Icon(Icons.exit_to_app),
                textColor: theme.colorScheme.error,
                iconColor: theme.colorScheme.error,
                onTap: widget.onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}