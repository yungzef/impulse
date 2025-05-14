import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

part 'ticket_state.dart';

class TicketCubit extends Cubit<TicketState> {
  final ApiClient _client;
  final Future<List<QuestionModel>> Function(ApiClient) _loader;

  TicketCubit(this._client, this._loader) : super(TicketInitial());

  Future<void> loadQuestions() async {
    emit(TicketLoading());
    try {
      final questions = await _loader(_client);
      emit(TicketLoaded(questions));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  Future<void> trackQuestionAnswer(String questionId, bool isCorrect) async {
    if (state is! TicketLoaded) return;

    try {
      await _client.trackQuestionAnswer(questionId, isCorrect);
      // Update the question's answered status in the state
      final currentState = state as TicketLoaded;
      final updatedQuestions = currentState.questions.map((question) {
        if (question.id == questionId) {
          return question.copyWith(wasAnsweredCorrectly: isCorrect);
        }
        return question;
      }).toList();

      emit(TicketLoaded(updatedQuestions));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> toggleFavorite(String questionId, bool isFavorite) async {
    if (state is! TicketLoaded) return;

    try {
      await _client.toggleFavorite(questionId, isFavorite);
      // Update the question's favorite status in the state
      final currentState = state as TicketLoaded;
      final updatedQuestions = currentState.questions.map((question) {
        if (question.id == questionId) {
          return question.copyWith(isFavorite: isFavorite);
        }
        return question;
      }).toList();

      emit(TicketLoaded(updatedQuestions));
    } catch (e) {
      // Handle error if needed
    }
  }
}