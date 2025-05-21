class QuestionModel {
  final String id;
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String explanation;
  final String? image;
  final bool? isFavorite;
  final bool? wasAnsweredCorrectly;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.explanation,
    this.image,
    this.isFavorite = false,
    this.wasAnsweredCorrectly,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',  // Обработка null для id
      question: json['question']?.toString() ?? '', // Обработка null для question
      answers: (json['answers'] as List<dynamic>?)?.cast<String>() ?? [], // Обработка null для answers
      correctIndex: json['correct_index'] as int? ?? 0, // Обработка null для correctIndex
      explanation: json['explanation']?.toString() ?? '', // Обработка null для explanation
      image: json['image']?.toString(), // image уже nullable
      isFavorite: json['is_favorite'] as bool? ?? false,
      wasAnsweredCorrectly: _parseNullableBool(json['was_answered_correctly']),
    );
  }

  static bool? _parseNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;  // Convert 1/0 to true/false
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return null;
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? answers,
    int? correctIndex,
    String? explanation,
    String? image,
    bool? isFavorite,
    bool? wasAnsweredCorrectly,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
      wasAnsweredCorrectly: wasAnsweredCorrectly ?? this.wasAnsweredCorrectly,
    );
  }
}