import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = true; // Начинаем с загрузки
  bool _isCheckingAuth = false;
  String? _errorMessage;
  final String _clientId = '147419489204-li6i7thuc59s5qm6mes1a1o7ehsp8kl3.apps.googleusercontent.com';
  final String _redirectUri = '${AppConfig.apiBaseUrl}/auth/google/callback';
  final String _scope = 'email profile openid';
  final String _tokenKey = 'oauth_tokens';
  final String _userKey = 'user_data';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAuth();
    });
  }

  Future<void> _initAuth() async {
    // 1. Сначала проверяем callback от Google
    await _handleAuthCallback();

    // 2. Если callback не сработал, проверяем сохраненную сессию
    if (!_isCheckingAuth) {
      await _checkExistingAuth();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _checkExistingAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final tokensJson = prefs.getString(_tokenKey);

    if (tokensJson != null) {
      try {
        final tokens = json.decode(tokensJson);
        final expiryDate = DateTime.parse(tokens['expiry_date']);

        if (expiryDate.isAfter(DateTime.now())) {
          // Токен действителен
          _navigateToHome(
            userId: tokens['user_id'],
            userEmail: tokens['email'],
            userName: tokens['name'],
          );
          return;
        }

        // Пробуем обновить токен
        if (tokens['refresh_token'] != null) {
          final newToken = await _refreshToken(tokens['refresh_token']);
          if (newToken != null) {
            // Обновляем данные в хранилище
            await _saveAuthData(
              userId: tokens['user_id'],
              accessToken: newToken,
              refreshToken: tokens['refresh_token'],
              email: tokens['email'],
              name: tokens['name'],
            );

            _navigateToHome(
              userId: tokens['user_id'],
              userEmail: tokens['email'],
              userName: tokens['name'],
            );
            return;
          }
        }
      } catch (e) {
        print('Error checking existing auth: $e');
        await prefs.remove(_tokenKey);
      }
    }

    // Если дошли сюда - нет валидной сессии
    setState(() => _isLoading = false);
  }

  Future<String?> _refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        body: {
          'client_id': _clientId,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return null;
  }

  Future<void> _handleAuthCallback() async {
    final uri = Uri.base;

    if (uri.queryParameters.containsKey('access_token')) {
      setState(() {
        _isLoading = true;
        _isCheckingAuth = true;
      });

      try {
        final accessToken = uri.queryParameters['access_token']!;
        final refreshToken = uri.queryParameters['refresh_token'];
        final userId = uri.queryParameters['sub'];
        final email = uri.queryParameters['email'];
        final name = uri.queryParameters['name'];

        if (userId == null || email == null) {
          throw Exception('Missing user data');
        }

        await _saveAuthData(
          userId: userId,
          accessToken: accessToken,
          refreshToken: refreshToken,
          email: email,
          name: name,
        );

        _navigateToHome(
          userId: userId,
          userEmail: email,
          userName: name!,
        );

        // Очищаем URL от параметров авторизации
        if (kIsWeb) {
          window.history.replaceState(null, '', '/');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Ошибка авторизации: ${e.toString()}';
          _isLoading = false;
          _isCheckingAuth = false;
        });
      }
    } else if (uri.queryParameters.containsKey('error')) {
      setState(() {
        _errorMessage = uri.queryParameters['error'];
        _isLoading = false;
        _isCheckingAuth = false;
      });
    }
  }

  Future<void> _saveAuthData({
    required String userId,
    required String accessToken,
    String? refreshToken,
    required String? email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(const Duration(seconds: 60 * 60 * 100)); // На 5 минут меньше, чем срок жизни токена

    final tokens = {
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'email': email,
      'name': name,
      'expiry_date': expiryDate.toIso8601String(),
    };

    await prefs.setString(_tokenKey, json.encode(tokens));
  }

  void _navigateToHome({
    required String userId,
    required String userEmail,
    required String userName,
  }) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userId: userId,
            userEmail: userEmail,
            userName: userName,
          ),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final state = _generateRandomString();
      final authUrl = Uri.parse(
        'https://accounts.google.com/o/oauth2/v2/auth?'
            'client_id=$_clientId&'
            'redirect_uri=$_redirectUri&'
            'response_type=code&'
            'scope=$_scope&'
            'state=$state&'
            'access_type=offline&'
            'prompt=consent',
      );

      if (kIsWeb) {
        window.location.href = authUrl.toString();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка авторизации: $e';
        _isLoading = false;
      });
    }
  }

  String _generateRandomString([int length = 32]) {
    final random = Random.secure();
    return base64Url.encode(List.generate(length, (i) => random.nextInt(256)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person,
                  size: 80),
              const SizedBox(height: 20),
              const Text(
                'Вітаємо!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Увійдіть до свого акаунта, щоб продовжити.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  label: Text('Увійти через Google', style: TextStyle(color: theme.colorScheme.background),),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _errorMessage!,
                      style:
                      const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}