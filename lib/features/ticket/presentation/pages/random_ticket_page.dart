import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/features/ticket/presentation/pages/ticket_page.dart';

class RandomTicketPage extends StatelessWidget {
  final String? userId;
  final Function onProgressUpdated;

  const RandomTicketPage({
    super.key,
    required this.userId,
    required this.onProgressUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return TicketPage(
      title: 'Випадковий білет',
      loader: (client) => client.getTicketRandom(),
      telegramUserId: userId,
    );
  }
}