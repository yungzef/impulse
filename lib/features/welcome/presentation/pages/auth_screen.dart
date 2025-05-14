import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:impulse/features/home/presentation/pages/home_page.dart';

String _getClientId() {
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  return isProduction
      ? '147419489204-m1obfqe2gn5pvg9nd66rolrq7olthis8.apps.googleusercontent.com'
      : '147419489204-mcv45kv1ndceffp1efnn2925cfet1ocb.apps.googleusercontent.com';
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: _getClientId(),
  scopes: ['email', 'profile'],
);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _userId;
  double _buttonWidth = 200;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _checkAuth().then((_) {
      if (_isLoggedIn) {
        _navigateToHome();
      }
    });
    _showTooltipTimer();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');
      _userId = prefs.getString('userId');
      _isLoading = false;
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userId: _userId, userName: _userName, userEmail: _userEmail,)),
    );
  }

  void _showTooltipTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && !_isLoggedIn) {
      setState(() => _showTooltip = true);
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) setState(() => _showTooltip = false);
    }
  }

  Future<void> _handleAuth() async {
    if (_isLoggedIn) {
      await _signOut();
    } else {
      await _signIn();
    }
  }

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
        _buttonWidth = 50;
      });

      final account = await _googleSignIn.signIn();
      if (account != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', account.email);
        await prefs.setString('userName', account.displayName ?? account.email);

        setState(() {
          _isLoggedIn = true;
          _userEmail = account.email;
          _userName = account.displayName ?? account.email;
          _userId = account.id;
        });

        _animationController.forward(from: 0);
        _navigateToHome();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка входа: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _buttonWidth = 200;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        _isLoggedIn = false;
        _userEmail = null;
        _userName = null;
        _userId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка выхода: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Логотип и заголовок
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_circle_rounded,
                                    size: isSmallScreen ? 60 : 80,
                                    color: colorScheme.primary,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .scale(begin: Offset(0.8, 0.8)),
                                const SizedBox(height: 24),
                                Text(
                                  _isLoggedIn ? 'Вітаємо з поверненням!' : 'Авторизація',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                                if (_userName != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _userName!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onBackground.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 40),

                            Text(
                              _isLoggedIn
                                  ? 'Ви авторизовані в системі'
                                  : 'Увійдіть для синхронізації прогресу',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _isLoggedIn
                                    ? colorScheme.errorContainer
                                    : colorScheme.primary,
                              ),
                              child: _isLoading
                                  ? Center(
                                child: CircularProgressIndicator(
                                  color: _isLoggedIn
                                      ? colorScheme.onErrorContainer
                                      : colorScheme.onPrimary,
                                ),
                              )
                                  : Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _handleAuth,
                                  child: Center(
                                    child: Text(
                                      _isLoggedIn ? 'Вийти' : 'Увійти з Google',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: _isLoggedIn
                                            ? colorScheme.onErrorContainer
                                            : colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (!_isLoggedIn) ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _navigateToHome,
                                child: Text(
                                  'Продовжити без входу',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Подсказка
                    if (_showTooltip)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Авторизуйтесь для збереження прогресу',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}