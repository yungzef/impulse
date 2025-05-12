import 'package:blobs/blobs.dart';
import 'package:impulse/features/welcome/widget/mock_progress_widget.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'learning_modes.dart';
import 'levitating_mockup.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print('Sign in error: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GoogleSignIn _googleSignIn;
  String? _userId;
  bool _isLoading = true;
  bool _gapiInitialized = false;
  bool _authInitialized = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await AuthService.isSignedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final account = await AuthService.signIn();
    setState(() {
      _isLoggedIn = account != null;
      _isLoading = false;
    });
  }


  String _getClientId() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction
        ? '147419489204-m1obfqe2gn5pvg9nd66rolrq7olthis8.apps.googleusercontent.com'
        : '147419489204-mcv45kv1ndceffp1efnn2925cfet1ocb.apps.googleusercontent.com';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 1000;
    final isTablet = MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 40 : 80,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.background.withOpacity(0.9),
                    theme.colorScheme.background,
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
                ),
                child: isMobile
                    ? _buildMobileHero(context, theme)
                    : _buildDesktopHero(context, theme),
              ),
            ),

            // Learning Modes
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
              ),
              child: LearningModes(userId: _userId),
            ),

            // Platform Features
            _buildPlatformFeatures(isMobile, isTablet, theme),

            // Smart Trainer
            _buildSmartTrainer(isMobile, theme),

            // Testing Modes
            _buildTestingModes(isMobile, theme),

            // Statistics
            _buildStatisticsSection(isMobile, theme),

            // Testimonials
            _buildTestimonials(isMobile, theme),

            // Mobile Version
            _buildMobileVersionSection(isMobile, theme),

            // FAQ Section
            _buildFAQSection(isMobile, theme),

            // Footer
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHero(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Підготуйся до іспиту в ТСЦ МВС',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onBackground,
            height: 1.2,
            fontSize: 50,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 12),
        Text(
          'Швидко, зручно, впевнено',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Актуальні тести, персональна статистика та розумна підготовка. '
              'Все, що потрібно, щоб скласти теорію з першого разу.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton(
            onPressed: _handleSignIn,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Почати підготовку',
              style: TextStyle(fontSize: 18, color: theme.colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildMockupSection(theme),
      ],
    );
  }

  Widget _buildDesktopHero(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Підготуйся до іспиту в ТСЦ МВС',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onBackground,
                  height: 1.2,
                  fontSize: 70,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              Text(
                'Швидко, зручно, впевнено',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Актуальні тести, персональна статистика та розумна підготовка.\n'
                    'Все, що потрібно, щоб скласти теорію з першого разу.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: _handleSignIn,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Почати підготовку',
                  style: TextStyle(
                    fontSize: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(child: _buildMockupSection(theme)),
      ],
    );
  }

  Widget _buildMockupSection(ThemeData theme) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Blob.animatedRandom(
            styles: BlobStyles(color: theme.colorScheme.primary),
            loop: true,
            size: 450,
            edgesCount: 5,
            minGrowth: 4,
            duration: const Duration(milliseconds: 5000),
          ),
          Positioned(
            left: 100,
            child: LevitatingMockup(
              imageAsset: 'assets/usage_mockup.png',
              width: 290,
              verticalShift: 6.0,
              scaleAmplitude: 0.01,
              animationDuration: const Duration(seconds: 5),
            ),
          ),
          Positioned(
            right: 100,
            child: LevitatingMockup(
              imageAsset: 'assets/app_mockup.png',
              width: 300,
              verticalShift: 12.0,
              scaleAmplitude: 0.03,
              animationDuration: const Duration(seconds: 4),
              startPhase: 0.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformFeatures(bool isMobile, bool isTablet, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
        vertical: isMobile ? 40 : 80,
      ),
      child: Column(
        children: [
          Text(
            'Вся теорія — в одному місці',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Impulse — це більше, ніж просто білети. Це система, яка допоможе тобі '
            'скласти іспит без зайвого стресу.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isMobile ? 1.5 : 1.2,
            children: [
              FeatureCard(
                icon: Icons.timer,
                title: 'Режим іспиту на час',
                color: const Color(0xFFFF7043),
              ),
              FeatureCard(
                icon: Icons.book,
                title: 'Усі теми ПДР по розділах',
                color: const Color(0xFF42A5F5),
              ),
              FeatureCard(
                icon: Icons.whatshot,
                title: '100 найскладніших запитань',
                color: const Color(0xFFEC407A),
              ),
              FeatureCard(
                icon: Icons.star,
                title: 'Вибране та помилки',
                color: const Color(0xFF66BB6A),
              ),
              FeatureCard(
                icon: Icons.analytics,
                title: 'Детальна статистика',
                color: const Color(0xFFFFCA28),
              ),
              FeatureCard(
                icon: Icons.psychology,
                title: 'Розумні підказки',
                color: const Color(0xFFAB47BC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartTrainer(bool isMobile, ThemeData theme) {
    return Stack(
      children: [
        Center(
          child: Image.asset(
            height: 450,
            fit: isMobile ? BoxFit.fitHeight : BoxFit.fitWidth,
            theme.brightness == Brightness.dark
                ? 'assets/macbook_mockup.png'
                : 'assets/macbook_mockup.png',
            width: double.infinity,
          ),
        ),
        Container(
          width: double.infinity,
          height: 450,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 40 : 80,
            horizontal: isMobile ? 16 : 24,
          ),
          color: theme.cardColor.withOpacity(0.7),
          child: Column(
            children: [
              Text(
                'Персональна стратегія підготовки',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
                child: Text(
                  'Сайт адаптується до твоїх відповідей. Він покаже, де ти помиляєшся, '
                  'запропонує складніші питання і допоможе підтягнути слабкі теми.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestingModes(bool isMobile, ThemeData theme) {
    return Container(
      color: theme.colorScheme.background,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      child: Column(
        children: [
          Text(
            'Обери свій режим',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ModeButton(
                icon: Icons.list_alt,
                label: 'Білет із 20 питань',
                color: const Color(0xFF66BB6A),
              ),
              ModeButton(
                icon: Icons.timer,
                label: 'Іспит на час',
                color: const Color(0xFFFF7043),
              ),
              ModeButton(
                icon: Icons.category,
                label: 'Тематичні тести',
                color: const Color(0xFF42A5F5),
              ),
              ModeButton(
                icon: Icons.whatshot,
                label: '100 складних',
                color: const Color(0xFFEC407A),
              ),
              ModeButton(
                icon: Icons.error,
                label: 'Помилки',
                color: const Color(0xFFFFCA28),
              ),
              ModeButton(
                icon: Icons.star,
                label: 'Вибране',
                color: const Color(0xFFAB47BC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(bool isMobile, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      color: theme.cardColor,
      child: Column(
        children: [
          Text(
            'Відстежуй свій прогрес',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
            child: Text(
              'Ти бачиш, які теми вже вивчив, а де ще треба попрацювати. '
              'Сайт нагадує, що повторити, і веде тебе до результату.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildTestimonials(bool isMobile, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      color: theme.colorScheme.background,
      child: Column(
        children: [
          Text(
            'Нам довіряють',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 40),
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Завдяки Impulse я здав іспит з першого разу. '
                    'Зручно, швидко, сучасно. Рекомендую кожному!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: const Color(0xFFFFCA28),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '4.9 із 5 — на основі 1200+ відгуків',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileVersionSection(bool isMobile, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      color: theme.cardColor,
      child: Column(
        children: [
          Text(
            'Підготовка завжди з тобою',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
            child: Text(
              'Сайт працює ідеально на смартфоні. Нічого встановлювати не треба — '
              'просто відкрий та навчайся будь-де.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              theme.brightness == Brightness.dark
                  ? 'assets/qr_code.png'
                  : 'assets/qr_code.png',
              width: 220,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(bool isMobile, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      color: theme.colorScheme.background,
      child: Column(
        children: [
          Text(
            'Маєш питання?',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Напиши нам — ми завжди відповімо.\n'
            'Хочеш запропонувати ідею? Нам цікаво!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Зв\'язатися з нами',
              style: TextStyle(fontSize: 18, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Text(
            '© Impulse, 2025',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tiktok),
                onPressed: () {},
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.facebook),
                onPressed: () {},
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Неофіційний навчальний ресурс. Тести відповідають актуальним білетам МВС.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ModeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: isMobile ? double.infinity : 180,
      height: isMobile ? 80 : 120,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.cardColor,
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMobile ? 24 : 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
