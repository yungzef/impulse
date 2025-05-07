// 📁 lib/features/home/widgets/progress_widget.dart

import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({super.key});

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  final _client = ApiClient();
  int total = 0, correct = 0, wrong = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final data = await _client.getProgress();
    setState(() {
      total = data['total'];
      correct = data['correct'];
      wrong = data['wrong'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? correct / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Прогресс: ${correct}/${total} (Ошибок: $wrong)'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percent),
      ],
    );
  }
}