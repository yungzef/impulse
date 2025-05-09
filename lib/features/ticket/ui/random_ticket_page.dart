import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class RandomTicketPage extends StatefulWidget {
  final String? telegramUserId;
  final Function onProgressUpdated;

  const RandomTicketPage({super.key, required this.telegramUserId, required this.onProgressUpdated});

  @override
  State<RandomTicketPage> createState() => _RandomTicketPageState();
}

class _RandomTicketPageState extends State<RandomTicketPage> {
  late final ApiClient _client;
  late Future<List<QuestionModel>> _questionsFuture;
  int _currentIndex = 0;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.telegramUserId);
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _questionsFuture = _client.getTicketRandom();
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

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
    });
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
        title: const Text('Случайный билет'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
            tooltip: 'Обновить вопросы',
          ),
        ],
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadQuestions,
                    child: Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Нет вопросов',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Попробуйте обновить список',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final questions = snapshot.data!;
          if (_currentIndex >= questions.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 48, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Вы ответили на все вопросы!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Начать заново'),
                    onPressed: _loadQuestions,
                  ),
                ],
              ),
            );
          }

          final question = questions[_currentIndex];
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (question.image != null && question.image!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
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
                SizedBox(height: 8),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24),
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
                    padding: EdgeInsets.only(bottom: 12),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: borderColor ?? Theme.of(context).colorScheme.outline,
                        ),
                        backgroundColor: backgroundColor,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                  SizedBox(height: 24),
                  Card(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(16),
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
                          SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: Text('Следующий вопрос'),
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