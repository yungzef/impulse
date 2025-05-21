import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';
import 'package:impulse/features/ticket/presentation/cubit/ticket_cubit.dart';

import '../../../../core/config/app_config.dart';
import 'html_renderer.dart';

String cleanHtml(String html) {
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '') // Удаление всех остальных тегов
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&mdash;', '—')
      .replaceAll('&laquo;', '«')
      .replaceAll('&raquo;', '»')
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .trim();
}

String removeQuestionNumberPrefix(String text) {
  final regex = RegExp(r'^№\s*\d+\s*', caseSensitive: false);
  return text.replaceFirst(regex, '').trim();
}

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
  bool _showExplanation = false;

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
      _showExplanation = false;
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
      // Создаем копию вопроса с измененным состоянием isFavorite
      final updatedQuestion = question.copyWith(
        isFavorite: !(question.isFavorite ?? false),
      );

      // Обновляем локальное состояние перед запросом
      setState(() {
        _questions?[_currentIndex] = updatedQuestion;
      });

      await _cubit.toggleFavorite(question.id, question.isFavorite);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedQuestion.isFavorite!
                ? 'Додано до обраного'
                : 'Видалено з обраного',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      // В случае ошибки возвращаем предыдущее состояние
      setState(() {
        _questions?[_currentIndex] = question;
      });

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
    final isDesktop = MediaQuery.of(context).size.width >= 720;

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
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
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
                  Text(state.message, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          } else if (state is TicketLoaded) {
            _questions = state.questions;
            return _buildQuestionView(state.questions, isDesktop);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildQuestionView(List<QuestionModel> questions, bool isDesktop) {
    if (_currentIndex >= questions.length) {
      return _buildCompletionView();
    }

    final question = questions[_currentIndex];
    final hasImage = question.image != null && question.image!.isNotEmpty;

    Widget questionContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Питання ${_currentIndex + 1} з ${questions.length}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          removeQuestionNumberPrefix(question.question),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                side: BorderSide(color: borderColor ?? Colors.grey),
                backgroundColor: backgroundColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                alignment: Alignment.centerLeft,
              ),
              onPressed:
                  _selectedAnswer == null
                      ? () => _handleAnswer(index, question)
                      : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      answer,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (icon != null) Icon(icon, size: 20, color: iconColor),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );

    Widget imageSection =
        hasImage
            ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                '${AppConfig.apiBaseUrl}/image?path=${question.image!}',
                fit: BoxFit.contain,
              ),
            )
            : Container();

    Widget explanationSection =
        _showExplanation
            ? Column(
              children: [
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Пояснення:',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            question.explanation
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
            : Container();

    Widget actionButtons = Column(
      children: [
        if (_selectedAnswer != null &&
            !_showExplanation &&
            question.explanation.isNotEmpty)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              alignment: Alignment.centerLeft,
            ),
            onPressed: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Пояснення:',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Text(
                    question.explanation,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface,)
                ),
              ],
            ),
          ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                question.isFavorite! ? Icons.star : Icons.star_outline,
                size: 20,
              ),
              onPressed: () => _toggleFavorite(question),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            if (_selectedAnswer != null)
              OutlinedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Наступне',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );

    Widget content =
        isDesktop && hasImage
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: imageSection,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      questionContent,
                      explanationSection,
                      const SizedBox(height: 16),
                      actionButtons,
                    ],
                  ),
                ),
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasImage) ...[imageSection, const SizedBox(height: 16)],
                questionContent,
                explanationSection,
                const SizedBox(height: 16),
                actionButtons,
              ],
            );

    return Column(
      children: [
        _buildQuestionNavigation(questions),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 4,
                ),
                const SizedBox(height: 16),
                content,
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
                _showExplanation = false;
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
                  _showExplanation = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color:
                      isCurrent
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
