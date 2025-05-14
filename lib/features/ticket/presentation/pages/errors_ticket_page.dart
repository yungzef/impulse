import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/features/ticket/presentation/pages/ticket_page.dart';

class ErrorsTicketPage extends StatelessWidget {
  final String? userId;
  final Function onProgressUpdated;

  const ErrorsTicketPage({
    super.key,
    required this.userId,
    required this.onProgressUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return TicketPage(
      title: 'Помилки',
      loader: (client) => client.getErrorQuestions(),
      telegramUserId: userId,
    );
  }
}