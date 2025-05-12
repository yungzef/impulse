// lib/core/services/api_client.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:impulse/data/models/question_model.dart';
import 'package:impulse/data/models/theme_model.dart';
import '../../core/config.dart';

class ApiClient {
  final Dio _dio;
  final String? userId;

  ApiClient({this.userId})
      : _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (status) => status != null && status < 500,
  )) {
    if (userId != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['telegram_id'] = userId;
          return handler.next(options);
        },
      ));
    }
  }

  Future<List<ThemeModel>> getThemes() async {
    try {
      final response = await _dio.get('/themes');
      return (response.data as List)
          .map((e) => ThemeModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load themes: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getThemeQuestions(int themeId) async {
    try {
      final response = await _dio.get('/themes/$themeId');
      return (response.data['questions'] as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load theme questions: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getTicketRandom() async {
    try {
      final response = await _dio.get(
        '/ticket/random',
        queryParameters: {'telegram_id': userId},
      );

      if (response.statusCode == 200) {
        return (response.data as List).map((q) => QuestionModel.fromJson(q)).toList();
      } else {
        throw Exception('Failed to get random ticket: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get random ticket: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getTicketErrors() async {
    try {
      final response = await _dio.get('/ticket/errors');
      return (response.data as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load error questions: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      return (response.data as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load favorites: ${e.message}');
    }
  }

  Future<void> addFavorite(int questionId) async {
    try {
      await _dio.post('/favorites/add',
          data: {'question_id': questionId});
    } on DioException catch (e) {
      throw Exception('Failed to add favorite: ${e.message}');
    }
  }

  Future<void> removeFavorite(int questionId) async {
    try {
      await _dio.post('/favorites/remove',
          data: {'question_id': questionId});
    } on DioException catch (e) {
      throw Exception('Failed to remove favorite: ${e.message}');
    }
  }

  Future<void> sendAnswer(int questionId, bool isCorrect) async {
    try {
      await _dio.post('/answer', data: {
        'question_id': questionId,
        'is_correct': isCorrect,
      });
    } on DioException catch (e) {
      throw Exception('Failed to send answer: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getProgress() async {
    try {
      final response = await _dio.get('/progress');
      return {
        'total': response.data['total'] ?? 0,
        'correct': response.data['correct'] ?? 0,
        'wrong': response.data['wrong'] ?? 0,
      };
    } on DioException catch (e) {
      throw Exception('Failed to load progress: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getErrorQuestions() async {
    try {
      final response = await _dio.get(
        '/user/errors',
        queryParameters: {'telegram_id': userId},
      );

      final data = response.data as Map<String, dynamic>;
      final questions = data['questions'] as List;

      return questions.map((q) => QuestionModel.fromJson(q)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load error questions: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getFavoriteQuestions() async {
    try {
      final response = await _dio.get(
        '/user/favorites',
        queryParameters: {'telegram_id': userId},
      );

      return (response.data as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load favorite questions: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await _dio.get(
        '/user/progress',
        queryParameters: {'telegram_id': userId},
      );

      if (response.statusCode == 200) {
        return {
          'total': response.data['total'] ?? 0,
          'correct': response.data['correct'] ?? 0,
          'wrong': response.data['wrong'] ?? 0,
          'accuracy': (response.data['accuracy'] ?? 0.0).toDouble(),
        };
      } else {
        throw Exception('Failed to load progress: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load progress: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getThemeProgress(int themeId) async {
    try {
      final response = await _dio.get(
        '/theme/progress',
        queryParameters: {
          'theme_id': themeId,
          'telegram_id': userId,
        },
      );
      return {
        'total': response.data['total'] ?? 0,
        'correct': response.data['correct'] ?? 0,
        'wrong': response.data['wrong'] ?? 0,
        'accuracy': (response.data['accuracy'] ?? 0.0).toDouble(),
        'last_question': response.data['last_question'] ?? 0,
      };
    } on DioException catch (e) {
      throw Exception('Failed to load theme progress: ${e.message}');
    }
  }

  Future<void> trackQuestionAnswer(String questionId, bool isCorrect) async {
    try {
      final response = await _dio.post(
        '/user/answer',
        data: {
          'question_id': questionId,
          'is_correct': isCorrect,
          'telegram_id': userId,
        },
        options: Options(
          contentType: Headers.jsonContentType,  // Явно указываем JSON
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save answer');
      }
    } on DioException catch (e) {
      throw Exception('Failed to track answer: ${e.message}');
    }
  }

  Future<void> toggleFavorite(String questionId, bool isFavorite) async {
    try {
      final response = await _dio.post(
        isFavorite ? '/user/favorites/add' : '/user/favorites/remove',
        data: jsonEncode({'question_id': questionId}),
        queryParameters: {'telegram_id': userId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle favorite: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to toggle favorite: ${e.message}');
    }
  }

  Future<void> addToFavorites(String questionId) async {
    try {
      await _dio.post(
        '/user/favorites/add',
        data: {'question_id': questionId},
        queryParameters: {'telegram_id': userId},
      );
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String questionId) async {
    try {
      await _dio.post(
        '/user/favorites/remove',
        data: {'question_id': questionId},
        queryParameters: {'telegram_id': userId},
      );
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<void> addToErrors(String questionId) async {
    try {
      await _dio.post(
        '/user/errors/add',
        data: {'question_id': questionId},
        queryParameters: {'telegram_id': userId},
      );
    } catch (e) {
      throw Exception('Failed to add to errors: $e');
    }
  }

  Future<void> removeFromErrors(String questionId) async {
    try {
      await _dio.post(
        '/user/errors/remove',
        data: {'question_id': questionId},
        queryParameters: {'telegram_id': userId},
      );
    } catch (e) {
      throw Exception('Failed to remove from errors: $e');
    }
  }

  // Добавьте в lib/core/services/api_client.dart
  Future<void> resetProgress() async {
    try {
      await _dio.post(
        '/user/reset',
        queryParameters: {'telegram_id': userId},
      );
    } on DioException catch (e) {
      throw Exception('Failed to reset progress: ${e.message}');
    }
  }

  Future<void> sendFeedback(String feedback, int rating) async {
    try {
      await _dio.post(
        '/feedback',
        data: {
          'feedback': feedback,
          'rating': rating,
          'telegram_id': userId,
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to send feedback: ${e.message}');
    }
  }
}

class AppConfig {
  static const apiBaseUrl = 'http://146.120.163.81:8000';
}