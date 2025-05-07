// lib/features/data/theme_repository.dart

import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/theme_model.dart';

class ThemeRepository {
  final ApiClient apiClient;

  ThemeRepository({required this.apiClient});

  Future<List<ThemeModel>> loadThemes() async {
    final List data = await apiClient.getThemes();

    return data.map((e) {
      return ThemeModel(
        index: e['index'],
        name: e['name'],
        questionCount: e['question_count'],
      );
    }).toList();
  }
}