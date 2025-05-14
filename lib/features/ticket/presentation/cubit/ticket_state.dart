part of 'ticket_cubit.dart';

abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final List<QuestionModel> questions;

  TicketLoaded(this.questions);
}

class TicketError extends TicketState {
  final String message;

  TicketError(this.message);
}