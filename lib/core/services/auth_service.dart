import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_html/html.dart' as html;

class AuthService {
  static const String _userIdKey = 'google_user_id';
  static const String _authTokenKey = 'google_auth_token';
  static const String _accessTokenKey = 'google_access_token';

  final GoogleSignIn _googleSignIn;

  AuthService() : _googleSignIn = GoogleSignIn(
    clientId: _getClientId(),
    scopes: ['email', 'profile', 'openid'],
  );

  static String _getClientId() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction
        ? '147419489204-m1obfqe2gn5pvg9nd66rolrq7olthis8.apps.googleusercontent.com'
        : '147419489204-mcv45kv1ndceffp1efnn2925cfet1ocb.apps.googleusercontent.com';
  }

  static String? get userId => html.window.localStorage[_userIdKey];
  static String? get authToken => html.window.localStorage[_authTokenKey];
  static String? get accessToken => html.window.localStorage[_accessTokenKey];
  static bool get isAuthenticated => userId != null && (authToken != null || accessToken != null);

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        await saveAuthData(
          account.id,
          auth.idToken ?? '',
          auth.accessToken ?? '',
        );
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      await clear();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static Future<void> saveAuthData(String userId, String idToken, String accessToken) async {
    html.window.localStorage[_userIdKey] = userId;
    if (idToken.isNotEmpty) {
      html.window.localStorage[_authTokenKey] = idToken;
    }
    if (accessToken.isNotEmpty) {
      html.window.localStorage[_accessTokenKey] = accessToken;
    }
  }

  static Future<void> clear() async {
    await html.window.localStorage.remove(_userIdKey);
    await html.window.localStorage.remove(_authTokenKey);
    await html.window.localStorage.remove(_accessTokenKey);
  }

  // Добавьте этот метод для инициализации при загрузке страницы
  static Future<void> init() async {
    final googleSignIn = GoogleSignIn(
      clientId: _getClientId(),
      scopes: ['email', 'profile', 'openid'],
    );
    if (isAuthenticated) {
      try {
        // Попытка автоматического входа при наличии данных
        await googleSignIn.signInSilently();
      } catch (e) {
        // Если автоматический вход не удался, очищаем данные
        await clear();
      }
    }
  }
}