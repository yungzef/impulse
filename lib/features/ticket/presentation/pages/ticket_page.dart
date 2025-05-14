import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';
import 'package:impulse/features/ticket/presentation/cubit/ticket_cubit.dart';

import '../../../../core/config/app_config.dart';

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
  late final TicketCubit _cubit;
  int _currentIndex = 0;
  int? _selectedAnswer;
  List<QuestionModel>? _questions;

  @override
  void initState() {
    super.initState();
    final client = ApiClient(userId: widget.telegramUserId);
    _cubit = TicketCubit(client, widget.loader)..loadQuestions();
    _currentIndex = widget.startFromIndex ?? 0;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
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
      await _cubit.trackQuestionAnswer(question.id, isCorrect);
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
      await _cubit.toggleFavorite(question.id, !question.isFavorite);
      // The cubit should handle the state update and emit a new state
      // which will trigger a rebuild through BlocBuilder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              !question.isFavorite ? 'Додано до обраного' : 'Видалено з обраного'),
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
        title: Text(widget.title),
        backgroundColor: colorScheme.surface,
      ),
      body: BlocBuilder<TicketCubit, TicketState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is TicketLoading) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary));
          } else if (state is TicketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Помилка завантаження',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          } else if (state is TicketLoaded) {
            _questions = state.questions;
            return _buildQuestionView(state.questions);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildQuestionView(List<QuestionModel> questions) {
    if (_currentIndex >= questions.length) {
      return _buildCompletionView();
    }

    final question = questions[_currentIndex];
    return Column(
      children: [
        _buildQuestionNavigation(questions),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 4,
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
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: const TextStyle(
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
                          color: borderColor ?? Colors.grey,
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
                            child: Text(answer),
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
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Наступне питання',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          question.isFavorite ? Icons.star : Icons.star_border,
                          color: Theme.of(context).colorScheme.secondary,
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
  }

  Widget _buildCompletionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Ви відповіли на всі питання!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Почати знову'),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _selectedAnswer = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigation(List<QuestionModel> questions) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.green
                      : isAnswered
                      ? isCorrect
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
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
}