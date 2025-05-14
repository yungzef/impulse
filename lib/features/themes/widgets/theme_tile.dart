import 'package:flutter/material.dart';
import 'package:impulse/data/models/theme_model.dart';

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
    final progress = theme.lastAnsweredIndex != null
        ? (theme.lastAnsweredIndex! + 1) / theme.questionCount
        : 0.0;
    final progressPercent = (progress * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).disabledColor,
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getThemeColor(theme.accuracy),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${theme.index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${theme.questionCount} питань',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).disabledColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(double? accuracy) {
    if (accuracy == null) return Colors.grey;
    if (accuracy > 0.7) return Colors.green;
    if (accuracy > 0.4) return Colors.orange;
    if (accuracy > 0.1) return Colors.red;
    return Colors.grey;
  }
}