// FILE: lib/features/ticket/ui/ticket_page.dart

import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class TicketPage extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function(ApiClient client) loader;

  const TicketPage({
    super.key,
    required this.title,
    required this.loader,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final _client = ApiClient();
  late Future<List<QuestionModel>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = widget.loader(_client).then((list) =>
        list.map((e) => QuestionModel.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет вопросов'));
          }

          final questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return ListTile(
                title: Text(q.question),
                subtitle: Text('Ответов: ${q.answers.length}'),
                onTap: () {}, // TODO: перейти к вопросу
              );
            },
          );
        },
      ),
    );
  }
}