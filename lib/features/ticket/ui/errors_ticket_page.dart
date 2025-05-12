// Файл: errors_ticket_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class ErrorsTicketPage extends StatefulWidget {
  final String? userId;
  final Function onProgressUpdated;

  const ErrorsTicketPage({
    super.key,
    required this.userId,
    required this.onProgressUpdated,
  });

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

      if (widget.onProgressUpdated != null) {
        widget.onProgressUpdated!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
          content: Text(
              question.isFavorite ? 'Додано до обраного' : 'Видалено з обраного'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Помилки'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.background,
            ],
          ),
        ),
        child: FutureBuilder<List<QuestionModel>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Помилка завантаження',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Спробувати знову'),
                    ),
                  ],
                ),
              );
            }

            final questions = snapshot.data ?? [];

            if (questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline,
                        size: 48, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Немає питань з помилками',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Дайте неправильні відповіді на питання,\nі вони з\'являться тут',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (_currentIndex >= questions.length) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        size: 48, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Ви відповіли на всі питання!',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Почати спочатку'),
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
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / questions.length,
                    backgroundColor: colorScheme.surfaceVariant,
                    color: colorScheme.primary,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 16),
                  if (question.image != null && question.image!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          '${AppConfig.apiBaseUrl}/image?path=${question.image!}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  Text(
                    'Питання ${_currentIndex + 1} з ${questions.length}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.question,
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...question.answers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final answer = entry.value;
                    final isCorrect = index == question.correctIndex;
                    final isSelected = _selectedAnswer == index;

                    Color borderColor = colorScheme.outline;
                    Color backgroundColor = Colors.transparent;
                    IconData? icon;
                    Color iconColor = Colors.transparent;

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
                            color: borderColor,
                            width: 2,
                          ),
                          backgroundColor: backgroundColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _selectedAnswer == null
                            ? () => _handleAnswer(index, question)
                            : null,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                answer,
                                style: TextStyle(
                                  color: colorScheme.onBackground,
                                  fontSize: 16,
                                ),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Пояснення:',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: TextStyle(
                              color: colorScheme.onBackground,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Наступне питання'),
                        ),
                        IconButton(
                          icon: Icon(
                            question.isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
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
      ),
    );
  }
}