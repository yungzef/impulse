// lib/data/models/theme_model.dart
import 'question_model.dart';

class ThemeModel {
  final int index;
  final String name;
  final int questionCount;
  final List<QuestionModel> questions;
  final int? lastAnsweredIndex; // Новое поле
  final double? accuracy;      // Новое поле

  ThemeModel({
    required this.index,
    required this.name,
    required this.questionCount,
    required this.questions,
    this.lastAnsweredIndex,
    this.accuracy,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      index: json['index'] ?? 0,
      name: json['name'] ?? '',
      questionCount: json['question_count'] ?? 0,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastAnsweredIndex: json['last_question'],
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
    );
  }

  ThemeModel copyWith({
    int? index,
    String? name,
    int? questionCount,
    List<QuestionModel>? questions,
    int? lastAnsweredIndex,
    double? accuracy,
  }) {
    return ThemeModel(
      index: index ?? this.index,
      name: name ?? this.name,
      questionCount: questionCount ?? this.questionCount,
      questions: questions ?? this.questions,
      lastAnsweredIndex: lastAnsweredIndex ?? this.lastAnsweredIndex,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}