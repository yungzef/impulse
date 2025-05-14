import 'dart:math';
import 'package:flutter/material.dart';

class MockProgressWidget extends StatelessWidget {
  const MockProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final progress = {
      'total': random.nextInt(200) + 50,
      'correct': random.nextInt(150) + 30,
      'wrong': random.nextInt(70) + 5,
      'accuracy': (random.nextDouble() * 0.5) + 0.4,
    };

    final accuracy = ((progress['accuracy'] as double) * 100).toStringAsFixed(1);
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ваш прогрес',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.refresh, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress['accuracy'] as double,
              minHeight: 12,
              backgroundColor: Theme.of(context).disabledColor,
              color: _getProgressColor(progress['accuracy'] as double),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text(
              '$accuracy% правильних відповідей',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  value: progress['total'].toString(),
                  label: 'Всього',
                  icon: Icons.format_list_numbered,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context,
                  value: progress['correct'].toString(),
                  label: 'Правильно',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatItem(
                  context,
                  value: progress['wrong'].toString(),
                  label: 'Помилки',
                  icon: Icons.error_outline,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double accuracy) {
    if (accuracy > 0.7) return Colors.green;
    if (accuracy > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatItem(
      BuildContext context, {
        required String value,
        required String label,
        required IconData icon,
        required Color color,
      }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}