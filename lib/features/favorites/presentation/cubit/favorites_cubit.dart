import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final ApiClient _client;

  FavoritesCubit(this._client) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await _client.getFavoriteQuestions();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> toggleFavorite(QuestionModel question) async {
    try {
      await _client.toggleFavorite(question.id, question.isFavorite);
      emit(FavoritesUpdated(question));
      await loadFavorites();
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: $e'));
    }
  }

  Future<void> refreshFavorites() async {
    if (state is FavoritesLoaded) {
      emit(FavoritesLoading());
      await loadFavorites();
    }
  }
}