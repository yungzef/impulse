class ThemeModel {
  final int index;
  final String name;
  final int questionCount;
  final int? lastAnsweredIndex;
  final double? accuracy;

  ThemeModel({
    required this.index,
    required this.name,
    required this.questionCount,
    this.lastAnsweredIndex,
    this.accuracy,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      index: json['index'],
      name: json['name'],
      questionCount: json['question_count'],
      lastAnsweredIndex: json['last_answered_index'],
      accuracy: json['accuracy']?.toDouble(),
    );
  }

  ThemeModel copyWith({
    int? index,
    String? name,
    int? questionCount,
    int? lastAnsweredIndex,
    double? accuracy,
  }) {
    return ThemeModel(
      index: index ?? this.index,
      name: name ?? this.name,
      questionCount: questionCount ?? this.questionCount,
      lastAnsweredIndex: lastAnsweredIndex ?? this.lastAnsweredIndex,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}