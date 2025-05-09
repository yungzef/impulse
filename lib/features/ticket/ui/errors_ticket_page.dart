// lib/features/ticket/ui/errors_ticket_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class ErrorsTicketPage extends StatefulWidget {
  final String? userId;
  final Function onProgressUpdated;

  const ErrorsTicketPage({super.key, required this.userId, required this.onProgressUpdated});

  @override
  State<ErrorsTicketPage> createState() => _ErrorsTicketPageState();
}

class _ErrorsTicketPageState extends State<ErrorsTicketPage> {
  late final ApiClient _client;
  late Future<List<QuestionModel>> _questionsFuture;
  int _currentIndex = 0;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.userId);
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _questionsFuture = _client.getErrorQuestions();
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
    });
  }

  void _handleAnswer(int index, QuestionModel question) async {
    setState(() => _selectedAnswer = index);

    try {
      final isCorrect = index == question.correctIndex;
      await _client.trackQuestionAnswer(question.id, isCorrect);

      // Обновляем прогресс
      if (widget.onProgressUpdated != null) {
        widget.onProgressUpdated!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleFavorite(QuestionModel question) async {
    try {
      await _client.toggleFavorite(question.id, !question.isFavorite);
      setState(() {
        question.isFavorite = !question.isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(question.isFavorite
              ? 'Добавлено в избранное'
              : 'Удалено из избранного'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ошибки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Нет вопросов с ошибками'),
                  SizedBox(height: 16),
                  Text('Ответьте неправильно на вопросы, и они появятся здесь'),
                ],
              ),
            );
          }

          if (_currentIndex >= questions.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Вы ответили на все вопросы!'),
                  ElevatedButton(
                    onPressed: _loadQuestions,
                    child: const Text('Начать заново'),
                  ),
                ],
              ),
            );
          }

          final question = questions[_currentIndex];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (question.image != null && question.image!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${AppConfig.apiBaseUrl}/image?path=${question.image!}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  'Вопрос ${_currentIndex + 1} из ${questions.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ...question.answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  final isCorrect = index == question.correctIndex;
                  final isSelected = _selectedAnswer == index;

                  Color? borderColor;
                  Color? backgroundColor;
                  IconData? icon;
                  Color? iconColor;

                  if (_selectedAnswer != null) {
                    if (isCorrect) {
                      borderColor = Colors.green;
                      backgroundColor = Colors.green.withOpacity(0.1);
                      icon = Icons.check;
                      iconColor = Colors.green;
                    } else if (isSelected) {
                      borderColor = Colors.red;
                      backgroundColor = Colors.red.withOpacity(0.1);
                      icon = Icons.close;
                      iconColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: borderColor ?? Theme.of(context).colorScheme.outline,
                        ),
                        backgroundColor: backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: _selectedAnswer == null
                          ? () => _handleAnswer(index, question)
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              answer,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (icon != null)
                            Icon(icon, size: 20, color: iconColor),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                if (_selectedAnswer != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Объяснение:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: const Text('Следующий вопрос'),
                      ),
                      IconButton(
                        icon: Icon(
                          question.isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => _toggleFavorite(question),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}