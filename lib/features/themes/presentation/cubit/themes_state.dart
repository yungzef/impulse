part of 'themes_cubit.dart';

abstract class ThemesState {}

class ThemesInitial extends ThemesState {}

class ThemesLoading extends ThemesState {}

class ThemesLoaded extends ThemesState {
  final List<ThemeModel> themes;

  ThemesLoaded(this.themes);
}

class ThemesError extends ThemesState {
  final String message;

  ThemesError(this.message);
}