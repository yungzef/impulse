// 📁 lib/core/services/api_client.dart

import 'package:dio/dio.dart';
import '../../core/config.dart';

class ApiClient {
  final Dio _dio;
  final String? telegramInitData;

  ApiClient({this.telegramInitData})
      : _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) {
        return status! < 500; // Принимаем все статусы меньше 500
      },
    ),
  ) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    if (telegramInitData != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['X-Telegram-InitData'] = telegramInitData;
            return handler.next(options);
          },
        ),
      );
    }
  }

  Future<List<dynamic>> getThemes() async {
    final res = await _dio.get('/themes');
    return res.data as List;
  }

  Future<List<dynamic>> getTicketRandom() async {
    final res = await _dio.get('/ticket/random');
    return res.data as List;
  }

  Future<List<dynamic>> getTicketErrors() async {
    final res = await _dio.get('/ticket/errors');
    return res.data as List;
  }

  // Пример обновлённого метода в ApiClient
  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      if (response.statusCode == 200) {
        return response.data as List;
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data}');
      }
      throw Exception('Dio error: ${e.message}');
    }
  }

  Future<void> addFavorite(int questionId) async {
    await _dio.post('/favorites/add', data: {'question_id': questionId});
  }

  Future<void> removeFavorite(int questionId) async {
    await _dio.post('/favorites/remove', data: {'question_id': questionId});
  }

  Future<void> sendAnswer(int questionId, bool isCorrect) async {
    await _dio.post('/answer', data: {
      'question_id': questionId,
      'is_correct': isCorrect,
    });
  }

  Future<Map<String, dynamic>> getProgress() async {
    final res = await _dio.get('/progress');
    return res.data as Map<String, dynamic>;
  }
}

class AppConfig {
  static const apiBaseUrl = 'http://127.0.0.1:8000/';
}
