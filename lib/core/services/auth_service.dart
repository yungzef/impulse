import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_html/html.dart' as html;

class AuthService {
  static const String _userIdKey = 'google_user_id';
  static const String _authTokenKey = 'google_auth_token';

  final GoogleSignIn _googleSignIn;

  AuthService() : _googleSignIn = GoogleSignIn(
    clientId: _getClientId(),
    scopes: ['email', 'profile'],
  );

  static String _getClientId() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction
        ? '147419489204-m1obfqe2gn5pvg9nd66rolrq7olthis8.apps.googleusercontent.com'
        : '147419489204-mcv45kv1ndceffp1efnn2925cfet1ocb.apps.googleusercontent.com';
  }

  static String? get userId => html.window.localStorage[_userIdKey];
  static String? get authToken => html.window.localStorage[_authTokenKey];
  static bool get isAuthenticated => userId != null && authToken != null;

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.idToken != null) {
          await saveAuthData(account.id, auth.idToken!);
        }
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

  static Future<void> saveAuthData(String userId, String authToken) async {
    html.window.localStorage[_userIdKey] = userId;
    html.window.localStorage[_authTokenKey] = authToken;
  }

  static Future<void> clear() async {
    await html.window.localStorage.remove(_userIdKey);
    await html.window.localStorage.remove(_authTokenKey);
  }
}