// lib/features/home/widgets/progress_widget.dart
import 'dart:math';

import 'package:flutter/material.dart';

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({super.key});

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  late Map<String, dynamic> _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateRandomProgress();
  }

  void _generateRandomProgress() {
    final random = Random();
    setState(() {
      _progress = {
        'total': random.nextInt(200) + 50,  // 50-250 questions
        'correct': random.nextInt(150) + 30,  // 30-180 correct
        'wrong': random.nextInt(70) + 5,  // 5-75 wrong
        'accuracy': (random.nextDouble() * 0.5) + 0.4,  // 40%-90% accuracy
      };
      _isLoading = false;
    });
  }

  void _refreshProgress() {
    setState(() => _isLoading = true);
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), _generateRandomProgress);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final accuracy = (_progress['accuracy'] * 100).toStringAsFixed(1);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ваш прогрес',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
                  onPressed: _refreshProgress,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress['accuracy'],
              minHeight: 12,
              backgroundColor: Theme.of(context).dividerColor,
              color: _getProgressColor(_progress['accuracy']),
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
                  value: _progress['total'].toString(),
                  label: 'Всього',
                  icon: Icons.format_list_numbered,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context,
                  value: _progress['correct'].toString(),
                  label: 'Правильно',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatItem(
                  context,
                  value: _progress['wrong'].toString(),
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