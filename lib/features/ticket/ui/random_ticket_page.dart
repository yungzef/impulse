// Файл: random_ticket_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class RandomTicketPage extends StatefulWidget {
  final String? telegramUserId;
  final Function onProgressUpdated;

  const RandomTicketPage({
    super.key,
    required this.telegramUserId,
    required this.onProgressUpdated,
  });

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
      widget.onProgressUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
        title: Text(
          'Випадковий білет',
          style: TextStyle(color: colorScheme.onBackground),
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _loadQuestions,
            tooltip: 'Оновити питання',
          ),
        ],
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Помилка завантаження',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Спробувати знову'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline,
                      size: 48, color: colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Немає питань',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Спробуйте оновити список',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
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
                  Icon(Icons.check_circle,
                      size: 48, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Ви відповіли на всі питання!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Почати знову'),
                    onPressed: _loadQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        '${AppConfig.apiBaseUrl}/image?path=${question.image!}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  'Питання ${_currentIndex + 1} з ${questions.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
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
                          color: borderColor ?? colorScheme.outline,
                        ),
                        backgroundColor: backgroundColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
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
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onBackground,
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
                  Card(
                    color: colorScheme.surfaceVariant,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Пояснення:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onBackground,
                            ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Наступне питання'),
                      ),
                      IconButton(
                        icon: Icon(
                          question.isFavorite
                              ? Icons.star
                              : Icons.star_border,
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