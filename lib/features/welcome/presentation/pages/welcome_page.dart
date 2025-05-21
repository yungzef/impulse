import 'package:blobs/blobs.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:impulse/features/welcome/presentation/pages/browser_required_page.dart';
import 'package:impulse/features/welcome/presentation/widgets/mock_progress_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../widgets/learning_modes.dart';
import '../../../home/widgets/levitating_mockup.dart';
import '../widgets/welcome_app_bar.dart';
import 'auth_page.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');

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
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isTablet = MediaQuery.of(context).size.width < 1300;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          WelcomeSliverAppBar(
            onLoginPressed: () {navigateToAuth();},
            onRegisterPressed: () {navigateToAuth();},
            onTopicsPressed: () {navigateToAuth();},
            onTicketPressed: () {navigateToAuth();},
          ),
          SliverToBoxAdapter(
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

                // Другие секции (раскомментируй по мере необходимости)
                _buildPlatformFeatures(isMobile, isTablet, theme),
                _buildSmartTrainer(isMobile, theme),
                _buildTestingModes(isMobile, isTablet, theme),
                _buildStatisticsSection(isMobile, theme),
                _buildTestimonials(isMobile, theme),
                _buildMobileVersionSection(isMobile, theme),
                _buildFAQSection(isMobile, theme),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantagesBlock(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;

    Widget buildAdvantage({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return Container(
        width: isMobile ? double.infinity : 300,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 40,
      ),
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            buildAdvantage(
              icon: Icons.verified,
              title: 'Офіційна база',
              subtitle:
                  'Ви вирішуєте саме ті питання, що будуть на іспиті в МВС',
            ),
            buildAdvantage(
              icon: Icons.devices,
              title: 'Єдиний доступ',
              subtitle:
                  'Один акаунт — і ви маєте доступ у додатку та веб-версії',
            ),
            buildAdvantage(
              icon: Icons.workspace_premium_outlined,
              title: 'Цілком безкоштовно',
              subtitle:
                  'Жодної плати за навчання — лише користуйтесь і готуйтесь',
            ),
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
              navigateToAuth();
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
                  navigateToAuth();
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
          if (mounted) SafeBlob(color: theme.colorScheme.primary),
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
          if (mounted) SafeBlob(color: theme.colorScheme.primary),
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

  double extraSpace = (16+16+9);

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
          Text(
            'Безліч корисної інформації для підготовки до іспиту та впевненого водіння',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: isMobile ? 32 : 42,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: theme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Описание с иконкой
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Офіційні білети 2025 року з поясненнями. Інтерактивні матеріали та '
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

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            childAspectRatio: ((MediaQuery.of(context).size.width - extraSpace) / (isMobile ? .75 : (isTablet ? 2 : 3))) / 241,
            children: List.generate(6, (index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: _calculateCardHeight(context, isMobile, isTablet),
                    // Общая высота для всех
                    child: _buildFeatureCard(
                      context,
                      icon: _getIconForIndex(index),
                      iconColor: _getColorForIndex(index),
                      title: _getTitleForIndex(index),
                      description: _getDescriptionForIndex(index),
                      progress: 1,
                      theme: theme,
                    ),
                  );
                },
              );
            }),
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

  // Функция для определения высоты
  double _calculateCardHeight(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    if (isMobile) return 220;
    if (isTablet) return 240;
    return 200; // Для десктопов
  }

  // Вспомогательные функции для демонстрации
  IconData _getIconForIndex(int index) {
    return [
      Icons.verified,
      Icons.traffic,
      Icons.quiz,
      Icons.analytics,
      Icons.gavel,
      Icons.question_answer,
    ][index];
  }

  Color _getColorForIndex(int index) {
    return [
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ][index];
  }

  String _getTitleForIndex(int index) {
    return [
      "Офіційні білети ТСЦ",
      "Дорожні знаки України",
      "Симулятор іспиту",
      "Аналіз помилок",
      "Регулювальник",
      "Пояснення",
    ][index];
  }

  String _getDescriptionForIndex(int index) {
    return [
      "Актуальні питання 2025 року з офіційною нумерацією",
      "Інтерактивний довідник з поясненнями",
      "Реальні умови тестування в ТСЦ",
      "Персональні рекомендації",
      "Хто такий регулювальник",
      "Розбір складних моментів",
    ][index];
  }

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
    return Card(
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
              // Заголовок с иконкой
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Описание
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Гибкое пространство
              const Spacer(),

              // Бейдж (если есть)
              if (isNew || isUpdated)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isNew ? Colors.green : Colors.blue).withOpacity(
                        0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isNew ? "НОВЕ" : "ОНОВЛЕНО",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isNew ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
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
          // Фонове зображення
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

          // Контент
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 50 : 50,
                vertical: isMobile ? 20 : 50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    'Готуйся до ПДР\nлегко та зручно',
                    style: TextStyle(
                      fontSize: isMobile ? 36 : 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -20),

                  const SizedBox(height: 24),

                  // Підзаголовок
                  Text(
                    'Безкоштовний сервіс для швидкої та ефективної підготовки',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Список переваг
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeaturePoint(
                        'Навчайся онлайн у будь-який час',
                        Icons.laptop_mac,
                      ),
                      _buildFeaturePoint(
                        'Повністю безкоштовно',
                        Icons.lock_open,
                      ),
                      // _buildFeaturePoint(
                      //   'Темами, а не просто тестами',
                      //   Icons.topic,
                      // ),
                      // _buildFeaturePoint(
                      //   'Зручний інтерфейс навіть з телефону',
                      //   Icons.smartphone,
                      // ),
                      _buildFeaturePoint(
                        'Статистика помилок і прогресу',
                        Icons.bar_chart,
                      ),
                      _buildFeaturePoint(
                        'Пояснення до кожного питання',
                        Icons.question_answer,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Кнопка
                  FilledButton(
                    onPressed: () {
                      navigateToAuth();
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
                      'Зареєструватися',
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

          // Декор
          if (!isMobile) ...[
            Positioned(
              right: 100,
              top: 100,
              child: Icon(
                Icons.lightbulb,
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

  Widget _buildTestingModes(bool isMobile, bool isTablet, ThemeData theme) {
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
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            childAspectRatio:
                isMobile
                    ? 3 * (width / 1000)
                    : isTablet
                    ? 1.5 * (width / 1000)
                    : 1 * (width / 1000),
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
                  TextButton(
                    onPressed: (){navigateToAuth();},
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Почати →",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
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

  bool isUnsafeBrowser(String ua) {
    final knownAgents = [
      'musical_ly', // старое имя TikTok
      'bytedancewebview', // TikTok WebView
      'tiktok', // на всякий случай
      'instagram',
      'fbav', // Facebook app
      'wv', // generic WebView
      'okhttp', // Android WebView
    ];

    return knownAgents.any((agent) => ua.contains(agent));
  }

  void navigateToAuth() {
    final ua = html.window.navigator.userAgent.toLowerCase();
    if (isUnsafeBrowser(ua)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BrowserRequiredPage()),
      );
    } else {
      if (isProduction) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
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
                onPressed: () async {
                  final Uri _url = Uri.parse(
                    'https://www.tiktok.com/@uaimpulsepdr',
                  );
                  if (!await launchUrl(_url)) {
                    throw Exception('Could not launch $_url');
                  }
                },
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Тести відповідають актуальним білетам МВС.',
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

class SafeBlob extends StatefulWidget {
  final Color color;

  const SafeBlob({super.key, required this.color});

  @override
  State<SafeBlob> createState() => _SafeBlobState();
}

class _SafeBlobState extends State<SafeBlob> {
  @override
  Widget build(BuildContext context) {
    return Blob.animatedRandom(
      styles: BlobStyles(color: widget.color),
      loop: true,
      size: 450,
      edgesCount: 5,
      minGrowth: 4,
      duration: const Duration(milliseconds: 5000),
    );
  }
}
