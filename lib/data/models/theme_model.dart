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
    // Add debug prints to identify which field might be causing issues
    json.forEach((key, value) {
      print('Field $key: $value (${value.runtimeType})');
      if (value.runtimeType == int && key.toLowerCase().contains('bool')) {
        print('⚠️ Potential bool field being sent as int: $key');
      }
    });
    print('Parsing theme: ${json['name']}');
    print('Fields: index=${json['index']} (${json['index'].runtimeType})');
    print('question_count=${json['question_count']} (${json['question_count'].runtimeType})');

    return ThemeModel(
      index: _safeParseInt(json['index']),
      name: _safeParseString(json['name']),
      questionCount: _safeParseInt(json['question_count']),
      lastAnsweredIndex: _safeParseNullableInt(json['last_answered_index']),
      accuracy: _safeParseNullableDouble(json['accuracy']),
    );
  }

// Add these helper methods to your ThemeModel class
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static String _safeParseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int? _safeParseNullableInt(dynamic value) {
    if (value == null) return null;
    return _safeParseInt(value);
  }

  static double? _safeParseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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