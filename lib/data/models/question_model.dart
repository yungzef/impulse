// lib/data/models/question_model.dart
class QuestionModel {
  final String id;  // Изменили с int на String
  final String question;
  final List<String> answers;
  final String correctAnswer;
  final int correctIndex;
  final String? image;
  final String explanation;
  bool isFavorite;
  bool? wasAnsweredCorrectly;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.correctIndex,
    this.image,
    required this.explanation,
    this.isFavorite = false,
    this.wasAnsweredCorrectly,
  });

  // Добавим метод для преобразования ID в int (если нужно)
  int get numericId {
    try {
      return int.parse(id.split('_').last);
    } catch (e) {
      return 0;
    }
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      correctIndex: json['correct_index'] ?? 0,
      image: json['image']?.toString(),
      explanation: json['explanation'] ?? '',
      isFavorite: json['is_favorite'] == true,
      wasAnsweredCorrectly: json['was_answered_correctly'],
    );
  }
}