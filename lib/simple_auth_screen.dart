import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:impulse/features/home/ui/main_menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
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
    _checkAuth();
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
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuPage(userId: _userId),
        ),
      );
    }
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
      setState(() {
        _isLoading = false;
        _buttonWidth = 200;
      });
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
      setState(() => _isLoading = false);
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

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Фоновые элементы
          Positioned(
            top: -250,
            right: -250,
            child: Blob.animatedRandom(
              styles: BlobStyles(color: theme.colorScheme.primary),
              loop: true,
              size: 650,
              edgesCount: 5,
              minGrowth: 4,
              duration: const Duration(milliseconds: 5000),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(),

          Positioned(
            bottom: -250,
            left: -250,
            child: Blob.animatedRandom(
              styles: BlobStyles(color: theme.colorScheme.primary),
              loop: true,
              size: 650,
              edgesCount: 5,
              minGrowth: 4,
              duration: const Duration(milliseconds: 5000),
            ),
          ).animate().fadeIn(duration: 700.ms).scale(),

          // Основной контент
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Логотип и заголовок
                  Column(
                        children: [
                          Icon(
                                Icons.account_circle_rounded,
                                size: 100,
                                color: colorScheme.primary,
                              )
                              .animate(
                                onPlay:
                                    (controller) =>
                                        controller.repeat(reverse: true),
                              )
                              .shimmer(duration: 2000.ms)
                              .scale(
                                end: Offset(1.05, 1.05),
                                duration: 2000.ms,
                              ),
                          const SizedBox(height: 24),
                          Text(
                            _isLoggedIn
                                ? 'С возвращением!'
                                : 'Войдите в аккаунт',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          if (_userName != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _userName!,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onBackground.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 40),

                  // Кнопка входа/выхода
                  AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _buttonWidth,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors:
                                _isLoggedIn
                                    ? [Colors.redAccent, Colors.red]
                                    : [
                                      colorScheme.primary,
                                      colorScheme.primaryContainer,
                                    ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child:
                            _isLoading
                                ? Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                                : Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: _handleAuth,
                                    child: Center(
                                      child: Text(
                                        _isLoggedIn
                                            ? 'Выйти'
                                            : 'Войти с Google',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),

                  // Подсказка
                  if (_showTooltip)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Войдите, чтобы сохранять прогресс',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.5, end: 0),

                  // Дополнительная информация
                  if (!_isLoggedIn)
                    Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Text(
                                'Преимущества входа:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onBackground.withOpacity(
                                    0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...[
                                'Синхронизация прогресса',
                                'Доступ на всех устройствах',
                                'Персональные рекомендации',
                              ].map(
                                (text) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: colorScheme.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        text,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onBackground
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ),

          // Эффект успешного входа
          if (_isLoggedIn)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _animationController.value,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.5,
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
