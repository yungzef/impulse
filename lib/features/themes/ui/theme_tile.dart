// features/themes/ui/theme_tile.dart
import 'package:flutter/material.dart';
import '../../../data/models/theme_model.dart';
import '../../domain/theme.dart';

// features/themes/ui/theme_tile.dart
class ThemeTile extends StatelessWidget {
  final ThemeModel theme;
  final VoidCallback onTap;

  const ThemeTile({
    super.key,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        title: Text(theme.name),
        subtitle: Text('Вопросов: ${theme.questionCount}'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}