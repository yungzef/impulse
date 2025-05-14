import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/theme_model.dart';

class ThemeRepository {
  final ApiClient apiClient;

  ThemeRepository({required this.apiClient});

  Future<List<ThemeModel>> loadThemes() async {
    try {
      final themes = await apiClient.getThemes();
      return themes;
    } catch (e) {
      throw Exception('Failed to load themes: $e');
    }
  }

  Future<Map<String, dynamic>> loadThemeProgress(int themeId) async {
    return await apiClient.getThemeProgress(themeId);
  }
}