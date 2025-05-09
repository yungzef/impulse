import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';

class ProgressWidget extends StatefulWidget {
  final String? userId;

  const ProgressWidget({super.key, required this.userId});

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  late final ApiClient _client;
  Map<String, dynamic> _progress = {
    'total': 0,
    'correct': 0,
    'wrong': 0,
    'accuracy': 0.0,
  };
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.userId);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final progress = await _client.getUserProgress();
      if (mounted) {
        setState(() {
          _progress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      debugPrint('Error loading progress: $e');
    }
  }

  void _refreshProgress() {
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            const Text('Ошибка загрузки прогресса'),
            TextButton(
              onPressed: _refreshProgress,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final accuracy = (_progress['accuracy'] * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ваш прогресс', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshProgress,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _progress['accuracy'],
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            color: _getProgressColor(_progress['accuracy']),
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Text(
            '$accuracy% правильных ответов',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Всего', _progress['total'].toString(), Icons.format_list_numbered),
              _buildStatItem('Правильно', _progress['correct'].toString(), Icons.check_circle),
              _buildStatItem('Ошибки', _progress['wrong'].toString(), Icons.error_outline),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double accuracy) {
    if (accuracy > 0.7) return Colors.green;
    if (accuracy > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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