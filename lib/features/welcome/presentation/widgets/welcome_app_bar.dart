import 'package:flutter/material.dart';

import '../pages/welcome_page.dart';

class WelcomeSliverAppBar extends StatelessWidget {
  final VoidCallback onTopicsPressed;
  final VoidCallback onTicketPressed;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  const WelcomeSliverAppBar({
    super.key,
    required this.onTopicsPressed,
    required this.onTicketPressed,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Про нас'),
            content: const Text(
              'Impulse PDR — це безкоштовна онлайн-платформа для підготовки до теоретичного іспиту з ПДР.\n\n'
              'Ми надаємо доступ до актуальних тестів, пояснень і відстеження прогресу. Платформа створена з любов’ю до учнів та з метою зробити процес навчання простим, ефективним і доступним для кожного.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрити'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    final isMobile = MediaQuery.of(context).size.width < 700;
    final isTablet = MediaQuery.of(context).size.width < 1100;

    return SliverAppBar(
      pinned: false,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      expandedHeight: 80,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? isMobile ? 40 : 70 : 130),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Імпульс',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 32),
                    if (isWideScreen) ...[
                      TextButton(
                        onPressed: onTopicsPressed,
                        child: Text(
                          'Теми',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onTicketPressed,
                        child: Text(
                          'Білет',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _showAboutDialog(context),
                        child: Text(
                          'Про нас',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isWideScreen) ...[
                  Row(
                    children: [
                      TextButton(
                        onPressed: onLoginPressed,
                        child: const Text('Вхід'),
                      ),
                      const SizedBox(width: 8),
                      // Кнопка
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onRegisterPressed,
                        child: const Text('Реєстрація'),
                      ),
                    ],
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _showFullScreenMenu(context),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: AnimatedBlobBackgroundVibrant(),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 28),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeInSlideUp(
                            delay: 100,
                            child: Text(
                              'Імпульс ПДР',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeInSlideUp(
                            delay: 200,
                            child: Text(
                              'Меню платформи',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ..._buildAnimatedButtons(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAnimatedButtons(BuildContext context) {
    final List<Map<String, VoidCallback>> menuItems = [
      {'Теми': onTopicsPressed},
      {'Білет': onTicketPressed},
      {'Про нас': () => _showAboutDialog(context)},
      {'Вхід': onLoginPressed},
      {'Реєстрація': onRegisterPressed},
    ];

    return List.generate(menuItems.length, (index) {
      final label = menuItems[index].keys.first;
      final callback = menuItems[index][label]!;

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + index * 100),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    elevation: 6,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    callback();
                  },
                  child: Text(label, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class AnimatedBlobBackgroundVibrant extends StatefulWidget {
  const AnimatedBlobBackgroundVibrant({super.key});

  @override
  State<AnimatedBlobBackgroundVibrant> createState() => _AnimatedBlobBackgroundVibrantState();
}

class _AnimatedBlobBackgroundVibrantState extends State<AnimatedBlobBackgroundVibrant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(-0.3, -0.2),
      end: const Offset(0.3, 0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withOpacity(0.2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * _animation.value.dy,
              left: MediaQuery.of(context).size.width * _animation.value.dx,
              child: SafeBlob(color: Theme.of(context).colorScheme.primary.withOpacity(.15),),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SafeBlob(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BlobShape extends StatelessWidget {
  final Color color;
  final double size;

  const BlobShape({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FadeInSlideUp extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeInSlideUp({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}