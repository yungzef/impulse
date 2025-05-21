import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';

class ProgressWidget extends StatefulWidget {
  final String? userId;

  const ProgressWidget({super.key, required this.userId});

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  late ApiClient _client;
  Map<String, dynamic> _progress = {
    'total': 0,
    'correct': 0,
    'wrong': 0,
    'accuracy': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.userId);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
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
        setState(() => _isLoading = false);
      }
      debugPrint('Progress load error: $e');
    }
  }

  void _refreshProgress() {
    setState(() => _isLoading = true);
    _loadProgress();
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
        padding: const EdgeInsets.all(32),
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
              backgroundColor: Theme.of(context).disabledColor,
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