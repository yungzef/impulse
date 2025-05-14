part of 'favorites_cubit.dart';

abstract class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<QuestionModel> favorites;
  const FavoritesLoaded(this.favorites);
}

class FavoritesUpdated extends FavoritesState {
  final QuestionModel question;
  const FavoritesUpdated(this.question);
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
}