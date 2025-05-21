import 'package:impulse/data/models/question_model.dart';

class SearchResult {
  final List<QuestionModel> questions;
  final String query;

  SearchResult({required this.questions, required this.query});
}