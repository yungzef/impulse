import 'package:universal_html/html.dart' as html;

class AuthStorage {
  static const String _tokenKey = 'auth_token';

  // Сохранить токен
  static void saveToken(String token) {
    html.window.localStorage[_tokenKey] = token;
  }

  // Получить токен
  static String? getToken() {
    return html.window.localStorage[_tokenKey];
  }

  // Удалить токен
  static void clearToken() {
    html.window.localStorage.remove(_tokenKey);
  }
}