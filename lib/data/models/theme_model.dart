// lib/data/models/theme_model.dart

class ThemeModel {
  final int index;
  final String name;
  final int questionCount;

  ThemeModel({
    required this.index,
    required this.name,
    required this.questionCount,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      index: json['index'] ?? 0,
      name: json['name'] ?? '',
      questionCount: json['question_count'] ?? 0,
    );
  }
}