// Файл: ticket_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class TicketPage extends StatefulWidget {
  final String title;
  final Future<List<QuestionModel>> Function(ApiClient) loader;
  final String? telegramUserId;
  final int? startFromIndex;

  const TicketPage({
    super.key,
    required this.title,
    required this.loader,
    this.telegramUserId,
    this.startFromIndex,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late final ApiClient _client;
  late Future<List<QuestionModel>> _questionsFuture;
  int _currentIndex = 0;
  int? _selectedAnswer;
  List<QuestionModel>? _questions;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.telegramUserId);
    _questionsFuture = widget.loader(_client);
    if (widget.startFromIndex != null) {
      _currentIndex = widget.startFromIndex!;
    }
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

  Widget _buildQuestionNavigation() {
    if (_questions == null) return const SizedBox();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _questions!.length,
          itemBuilder: (context, index) {
            final question = _questions![index];
            final isAnswered = question.wasAnsweredCorrectly != null;
            final isCorrect = question.wasAnsweredCorrectly == true;
            final isCurrent = _currentIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                  _selectedAnswer = null;
                });
              },
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                scale: isCurrent ? 1.0 : 0.8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? colorScheme.primary
                        : isAnswered
                        ? isCorrect
                        ? colorScheme.primary.withOpacity(0.8)
                        : colorScheme.error.withOpacity(0.8)
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? colorScheme.onPrimary.withOpacity(0.9)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isCurrent
                            ? colorScheme.onPrimary
                            : colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: isCurrent ? 18 : 16,
                      ),
                      child: Text('${index + 1}'),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: colorScheme.onBackground),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Помилка: ${snapshot.error}',
                style: TextStyle(color: colorScheme.onBackground),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Немає питань',
                style: TextStyle(color: colorScheme.onBackground),
              ),
            );
          }

          _questions = snapshot.data!;

          if (_currentIndex >= _questions!.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ви відповіли на всі питання!',
                    style: TextStyle(
                        color: colorScheme.onBackground, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Повернутись назад'),
                  ),
                ],
              ),
            );
          }

          final question = _questions![_currentIndex];
          return Column(
            children: [
              _buildQuestionNavigation(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions!.length,
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
                        'Питання ${_currentIndex + 1} з ${_questions?.length}',
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
                                vertical: 16,
                                horizontal: 16,
                              ),
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
                                        color: colorScheme.onBackground),
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
                                      color: colorScheme.onBackground),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}