import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';
import '../../data/models/question_model.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  final String? userId;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.userId,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final ApiClient _client;
  late Future<List<QuestionModel>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.userId);
    _searchFuture = _client.searchQuestions(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Результати пошуку: "${widget.query}"'),
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          }

          final questions = snapshot.data!;

          if (questions.isEmpty) {
            return Center(
              child: Text(
                'Нічого не знайдено за запитом "${widget.query}"',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(question.question),
                  onTap: () => _navigateToQuestion(context, question),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToQuestion(BuildContext context, QuestionModel question) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => QuestionDetailPage(
    //       question: question,
    //       userId: widget.userId,
    //     ),
    //   ),
    // );
  }
}