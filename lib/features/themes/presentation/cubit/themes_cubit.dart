import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/data/models/theme_model.dart';
import 'package:impulse/data/repositories/theme_repository_impl.dart';

part 'themes_state.dart';

class ThemesCubit extends Cubit<ThemesState> {
  final ThemeRepository _repository;

  ThemesCubit(this._repository) : super(ThemesInitial());

  Future<void> loadThemesWithProgress() async {
    emit(ThemesLoading());
    try {
      var themes = await _repository.loadThemes();

      List<ThemeModel> updatedThemes = [];
      for (var theme in themes) {
        final progress = await _repository.loadThemeProgress(theme.index);
        updatedThemes.add(theme.copyWith(
          lastAnsweredIndex: progress['last_question'],
          accuracy: progress['accuracy'],
        ));
      }

      emit(ThemesLoaded(updatedThemes));
    } catch (e) {
      emit(ThemesError(e.toString()));
    }
  }

  Future<void> refreshThemes() async {
    emit(ThemesLoading());
    try {
      await loadThemesWithProgress();
    } catch (e) {
      emit(ThemesError(e.toString()));
    }
  }
}