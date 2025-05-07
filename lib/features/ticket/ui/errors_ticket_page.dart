// lib/features/ticket/ui/errors_ticket_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class ErrorsTicketPage extends StatefulWidget {
  const ErrorsTicketPage({super.key});

  @override
  State<ErrorsTicketPage> createState() => _ErrorsTicketPageState();
}

class _ErrorsTicketPageState extends State<ErrorsTicketPage> {
  final _client = ApiClient();
  late Future<List<QuestionModel>> _questionsFuture;
  int _currentIndex = 0;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _questionsFuture = _client.getTicketErrors().then((list) =>
          list.map((e) => QuestionModel.fromJson(e)).toList());
    });
  }

  void _handleAnswer(int index, QuestionModel question) {
    setState(() {
      _selectedAnswer = index;
    });

    _client.sendAnswer(
      question.correctIndex,
      index == question.correctIndex,
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибки')),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет вопросов с ошибками'));
          }

          final questions = snapshot.data!;
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
                if (question.image != null)
                  Image.network(question.image!),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...question.answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  final isCorrect = index == question.correctIndex;
                  final isSelected = _selectedAnswer == index;

                  Color? color;
                  if (_selectedAnswer != null) {
                    color = isCorrect
                        ? Colors.green
                        : isSelected ? Colors.red : null;
                  }

                  return Card(
                    color: color?.withOpacity(0.1),
                    child: ListTile(
                      title: Text(answer),
                      onTap: () => _handleAnswer(index, question),
                      trailing: _selectedAnswer != null && isCorrect
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Text(
                  _selectedAnswer != null ? question.explanation : '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_selectedAnswer != null)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Text('Следующий вопрос'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}