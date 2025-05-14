import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiClient _apiClient;

  HomeCubit(this._apiClient) : super(HomeInitial());

  Future<void> loadProgress() async {
    emit(HomeLoading());
    try {
      final progress = await _apiClient.getUserProgress();
      emit(HomeLoaded(progress));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}