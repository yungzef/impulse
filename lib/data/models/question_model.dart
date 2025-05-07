// lib/data/models/question_model.dart

class QuestionModel {
  final String question;
  final List<String> answers;
  final String correctAnswer;
  final int correctIndex;
  final String? image;
  final String explanation;

  QuestionModel({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.correctIndex,
    required this.image,
    required this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      correctIndex: json['correct_index'] ?? 0,
      image: json['image'],
      explanation: json['explanation'] ?? '',
    );
  }
}