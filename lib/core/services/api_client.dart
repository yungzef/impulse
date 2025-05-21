import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:impulse/core/config/app_config.dart';
import 'package:impulse/core/constants/app_constants.dart';
import 'package:impulse/data/models/question_model.dart';
import 'package:impulse/data/models/theme_model.dart';

class ApiClient {
  final Dio _dio;
  final String? userId;

  ApiClient({required this.userId})
      : _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConstants.apiTimeout,
    receiveTimeout: AppConstants.apiTimeout,
    validateStatus: (status) => status != null && status < 500,
  )) {
    if (userId != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['user_id'] = userId;
          return handler.next(options);
        },
      ));
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
      ));
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['user_id'] = userId;
          print('Adding user_id: $userId to request'); // Логирование
          return handler.next(options);
        },
      ));
    }
  }

  Future<void> sendLogsToServer(String? log) async {
    if (log == null || log.isEmpty) return;

    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));

    try {
      await dio.post(
        '/logs',
        data: {'log': log, 'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      // Не выводим ошибку в проде
    }
  }

  Future<List<ThemeModel>> getThemes() async {
    try {
      final response = await _dio.get('/themes');

      // Debug print to verify response structure
      print('Raw API response: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((e) => ThemeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format - expected List');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load themes: ${e.message}');
    }
  }


  Future<List<QuestionModel>> getThemeQuestions(int themeId) async {
    try {
      final response = await _dio.get(
        '/themes/$themeId'
      );

      return (response.data['questions'] as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load theme questions: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getTicketRandom({String? userId}) async {
    try {
      final response = await _dio.get(
        '/ticket/random',
        queryParameters: userId != null ? {'user_id': userId} : null,
      );
      return (response.data as List).map((q) => QuestionModel.fromJson(q)).toList();
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
      await _dio.post('/favorites/add', data: {'question_id': questionId});
    } on DioException catch (e) {
      throw Exception('Failed to add favorite: ${e.message}');
    }
  }

  Future<void> removeFavorite(int questionId) async {
    try {
      await _dio.post('/favorites/remove', data: {'question_id': questionId});
    } on DioException catch (e) {
      throw Exception('Failed to remove favorite: ${e.message}');
    }
  }

  Future<void> sendAnswer(String questionId, bool isCorrect) async {
    await _dio.post(
      '/user/answer',
      data: {
        'question_id': questionId,
        'is_correct': isCorrect,
        'user_id': userId, // Теперь передается явно
      },
    );
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
      print('Fetching errors for user: $userId'); // Логирование
      final response = await _dio.get('/user/errors');
      return (response.data['questions'] as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      print('Error loading errors: ${e.response?.data}');
      throw Exception('Failed to load errors: ${e.message}');
    }
  }

  Future<List<QuestionModel>> getFavoriteQuestions() async {
    try {
      final response = await _dio.get(
        '/user/favorites',
        queryParameters: {'user_id': userId},
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
        queryParameters: {'user_id': userId},
      );
      return {
        'total': response.data['total'] ?? 0,
        'correct': response.data['correct'] ?? 0,
        'wrong': response.data['wrong'] ?? 0,
        'accuracy': (response.data['accuracy'] ?? 0.0).toDouble(),
      };
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
          'user_id': userId,
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
      await _dio.post(
        '/user/answer',
        data: {
          'question_id': questionId,
          'is_correct': isCorrect,
          'user_id': userId,
        },
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      throw Exception('Failed to track answer: ${e.message}');
    }
  }

  Future<List<QuestionModel>> searchQuestions(String query) async {
    try {
      final response = await _dio.get(
        '/search/questions',
        queryParameters: {'query': query},
      );
      return (response.data['results'] as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Search failed: ${e.message}');
    }
  }

  Future<void> toggleFavorite(String questionId, bool? isCurrentlyFavorite) async {
    try {
      // Если isCurrentlyFavorite == null или false, значит, вопрос НЕ в избранном → добавляем
      final shouldAdd = isCurrentlyFavorite != true;

      final response = await _dio.post(
        shouldAdd ? '/user/favorites/add' : '/user/favorites/remove',
        data: jsonEncode({'question_id': questionId}),
        queryParameters: {'user_id': userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle favorite: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to toggle favorite: ${e.message}');
    }
  }

  Future<void> resetProgress() async {
    try {
      await _dio.post(
        '/user/reset',
        queryParameters: {'user_id': userId},
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
          'user_id': userId,
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to send feedback: ${e.message}');
    }
  }
}