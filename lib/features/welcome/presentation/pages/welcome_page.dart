import 'package:blobs/blobs.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:impulse/features/welcome/presentation/widgets/mock_progress_widget.dart';
import 'package:impulse/features/welcome/presentation/pages/auth_screen.dart';

import '../widgets/learning_modes.dart';
import '../../../home/widgets/levitating_mockup.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                child:
                    isMobile
                        ? _buildMobileHero(context, theme)
                        : _buildDesktopHero(context, theme),
              ),
            ),

            // Learning Modes
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
              ),
              child: LearningModes(),
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
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
        _buildMobileMockupSection(theme),
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
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
        Expanded(child: _buildDesktopMockupSection(theme)),
      ],
    );
  }

  Widget _buildDesktopMockupSection(ThemeData theme) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (mounted)
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

  Widget _buildMobileMockupSection(ThemeData theme) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (mounted)
            Blob.animatedRandom(
              styles: BlobStyles(color: theme.colorScheme.primary),
              loop: true,
              size: 300,
              edgesCount: 5,
              minGrowth: 4,
              duration: const Duration(milliseconds: 5000),
            ),
          Positioned(
            left: 20,
            child: LevitatingMockup(
              imageAsset: 'assets/usage_mockup.png',
              width: 250,
              verticalShift: 6.0,
              scaleAmplitude: 0.01,
              animationDuration: const Duration(seconds: 5),
            ),
          ),
          Positioned(
            right: 20,
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
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 64 : 124),
        vertical: isMobile ? 40 : 80,
      ),
      child: Column(
        children: [
          // Заголовок с анимацией
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary,
                  ],
                  stops: [0.3, 0.7],
                ).createShader(bounds),
            child: Text(
              'Безліч корисної інформації для підготовки до іспиту та впевненого водіння',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: isMobile ? 32 : 42,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Описание с иконкой
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Офіційні білети 2024 року з поясненнями. Інтерактивні матеріали та '
                  'персональні рекомендації для ефективної підготовки до іспиту в ТСЦ.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Основная сетка фич
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio:
                isMobile
                    ? 3.5 * (width / 1000)
                    : (isTablet ? 3 * (width / 2000) : 2 * (width / 2000)),
            children: [
              // 1. Официальные билеты
              _buildFeatureCard(
                context,
                icon: Icons.verified,
                iconColor: Colors.green,
                title: "Офіційні білети ТСЦ",
                description:
                    "Актуальні питання 2024 року з офіційною нумерацією",
                progress: 1,
                theme: theme,
              ),

              // 2. Дорожные знаки
              _buildFeatureCard(
                context,
                icon: Icons.traffic,
                iconColor: Colors.orange,
                title: "Дорожні знаки України",
                description: "Інтерактивний довідник з поясненнями",
                progress: 1,
                theme: theme,
              ),

              // 3. Симулятор экзамена
              _buildFeatureCard(
                context,
                icon: Icons.quiz,
                iconColor: Colors.blue,
                title: "Симулятор іспиту",
                description: "Реальні умови тестування в ТСЦ",
                progress: 1,
                theme: theme,
                isNew: true,
              ),

              // 4. Разбор ошибок
              _buildFeatureCard(
                context,
                icon: Icons.analytics,
                iconColor: Colors.purple,
                title: "Аналіз помилок",
                description: "Персональні рекомендації",
                progress: 1,
                theme: theme,
              ),

              // 5. Законодательство
              _buildFeatureCard(
                context,
                icon: Icons.gavel,
                iconColor: Colors.red,
                title: "Регулювальник",
                description: "Хто такий регулювальник",
                progress: 1,
                theme: theme,
              ),

              // 6. Видеоуроки
              _buildFeatureCard(
                context,
                icon: Icons.question_answer,
                iconColor: Colors.teal,
                title: "Пояснення",
                description: "Розбір складних моментів",
                progress: 1,
                theme: theme,
                isUpdated: true,
              ),
            ],
          ),

          // Дополнительная статистика
          if (!isMobile) ...[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      "2200+",
                      "питань у базі",
                      Icons.library_books,
                    ),
                    _buildStatItem(
                      "95%",
                      "успішних користувачів",
                      Icons.emoji_events,
                    ),
                    _buildStatItem(
                      "24/7",
                      "доступ до матеріалів",
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Вспомогательный метод для создания карточек фич
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required double progress,
    required ThemeData theme,
    bool isNew = false,
    bool isUpdated = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "НОВЕ",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isUpdated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "ОНОВЛЕНО",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для статистики
  Widget _buildStatItem(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 36, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartTrainer(bool isMobile, ThemeData theme) {
    return SizedBox(
      height: isMobile ? 700 : 900,
      width: double.infinity,
      child: Stack(
        children: [
          // Фоновое изображение на весь экран
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/macbook_mockup.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Контент поверх изображения
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 50 : 100,
                vertical: 50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с эффектом
                  Text(
                    'Персональний\nтренер ПДР',
                    style: TextStyle(
                      fontSize: isMobile ? 36 : 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -20),

                  const SizedBox(height: 24),

                  // Подзаголовок
                  Text(
                    'Адаптивна система, що навчається разом з вами',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Список преимуществ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeaturePoint(
                        'Аналізує ваші помилки',
                        Icons.analytics,
                      ),
                      _buildFeaturePoint(
                        'Підбирає індивідуальні завдання',
                        Icons.person_search,
                      ),
                      _buildFeaturePoint(
                        'Фокусує на слабких місцях',
                        Icons.auto_fix_high,
                      ),
                      _buildFeaturePoint(
                        'Показує прогрес у реальному часі',
                        Icons.timeline,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Кнопка CTA
                  FilledButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Спробувати безкоштовно',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Декоративные элементы
          if (!isMobile) ...[
            Positioned(
              right: 100,
              top: 100,
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturePoint(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingModes(bool isMobile, ThemeData theme) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Анимированный заголовок
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback:
                (bounds) => RadialGradient(
                  center: Alignment.topLeft,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary,
                  ],
                ).createShader(bounds),
            child: Text(
              'Режими підготовки',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: isMobile ? 32 : 42,
                fontWeight: FontWeight.w800,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          Text(
            'Адаптуйте підготовку під свої потреби',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 40),

          // Основные режимы тестирования
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : (!isMobile ? 2 : 3),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio:
                isMobile ? 3 * (width / 1000) : 1.6 * (width / 1000),
            padding: const EdgeInsets.all(8),
            children: [
              _buildTestModeCard(
                context,
                icon: Icons.assignment,
                title: "Офіційні білети",
                subtitle: "40 білетів по 20 питань",
                color: Colors.green,
                time: "≈ 20 хв",
                questions: "800 питань",
                theme: theme,
              ),

              _buildTestModeCard(
                context,
                icon: Icons.timer,
                title: "Екзаменаційний режим",
                subtitle: "Симуляція іспиту в ТСЦ",
                color: Colors.orange,
                time: "20 хв",
                questions: "20 питань",
                theme: theme,
                isPopular: true,
              ),

              _buildTestModeCard(
                context,
                icon: Icons.category,
                title: "Тематичні тести",
                subtitle: "За розділами ПДР",
                color: Colors.blue,
                time: "Вільний",
                questions: "27 тем",
                theme: theme,
              ),

              _buildTestModeCard(
                context,
                icon: Icons.whatshot,
                title: "Складні питання",
                subtitle: "Топ-100 помилок",
                color: Colors.red,
                time: "≈ 30 хв",
                questions: "100 питань",
                theme: theme,
              ),

              _buildTestModeCard(
                context,
                icon: Icons.error_outline,
                title: "Робота над помилками",
                subtitle: "Персональний аналіз",
                color: Colors.yellow,
                time: "Вільний",
                questions: "Індивідуально",
                theme: theme,
              ),

              _buildTestModeCard(
                context,
                icon: Icons.star_rate,
                title: "Мої закладки",
                subtitle: "Збережені питання",
                color: Colors.purple,
                time: "Вільний",
                questions: "Індивідуально",
                theme: theme,
              ),
            ],
          ),

          // Дополнительная информация
          if (!isMobile) ...[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Для успішного складання іспиту рекомендуємо пройти всі теми '
                        'хоча б один раз та зосередитись на питаннях, де ви найчастіше помиляєтесь.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Вспомогательный метод для создания карточек режимов
  Widget _buildTestModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String time,
    required String questions,
    required ThemeData theme,
    bool isPopular = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        highlightColor: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              if (isPopular)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "ПОПУЛЯРНИЙ",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Column(
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
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetaInfo(Icons.access_time, time, theme),
                      const SizedBox(width: 16),
                      _buildMetaInfo(Icons.help_outline, questions, theme),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Почати →",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для мета-информации
  Widget _buildMetaInfo(IconData icon, String text, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(bool isMobile, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Заголовок с пояснением
          Column(
            children: [
              Text(
                'Твій прогрес у навчанні',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
                child: Text(
                  'Це приклад того, як ти зможеш відстежувати свої успіхи в майбутньому. '
                  'Після початку навчання тут з\'явиться твоя персональна статистика:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Контейнер с примером статистики
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                // Заголовок примера
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Приклад статистики',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Сам виджет статистики
                MockProgressWidget(),

                // Пояснение под виджетом
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Тут буде відображатися твій прогрес по темах, кількість правильних '
                    'відповідей та питання, які варто повторити перед іспитом.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
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
          // const SizedBox(height: 20),
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: theme.colorScheme.surface,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Image.asset(
          //     theme.brightness == Brightness.dark
          //         ? 'assets/qr_code.png'
          //         : 'assets/qr_code.png',
          //     width: 220,
          //   ),
          // ),
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
