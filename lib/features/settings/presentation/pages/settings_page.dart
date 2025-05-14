import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';

class SettingsPage extends StatefulWidget {
  final String? userId;

  const SettingsPage({super.key, required this.userId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скинути прогрес?'),
        content: const Text('Усі ваші результати будуть видалені. Ви впевнені?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Скинути', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final client = ApiClient(userId: widget.userId);
        await client.resetProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Прогрес скинуто')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('Налаштування'),
        backgroundColor: const Color(0xFF1C1C1E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Загальні',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SwitchListTile(
            title: const Text('Темна тема', style: TextStyle(color: Colors.white)),
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
          ),
          SwitchListTile(
            title: const Text('Сповіщення', style: TextStyle(color: Colors.white)),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          SwitchListTile(
            title: const Text('Звукові ефекти', style: TextStyle(color: Colors.white)),
            value: _soundEffects,
            onChanged: (value) => setState(() => _soundEffects = value),
          ),
          const Divider(color: Colors.grey),
          const Text(
            'Обліковий запис',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          ListTile(
            title: const Text('Скинути прогрес', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.delete, color: Colors.white),
            onTap: _resetProgress,
          ),
          const Divider(color: Colors.grey),
          const Text(
            'Про додаток',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          ListTile(
            title: const Text('Версія', style: TextStyle(color: Colors.white)),
            subtitle: const Text('1.0.0', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.info, color: Colors.white),
          ),
        ],
      ),
    );
  }
}