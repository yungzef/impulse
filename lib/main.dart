import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:impulse/core/theme/app_theme.dart';
import 'package:impulse/features/welcome/presentation/pages/welcome_page.dart';
import 'package:impulse/features/welcome/presentation/pages/browser_required_page.dart';
import 'package:universal_html/html.dart' as html;

import 'core/injection.dart';
import 'core/services/api_client.dart';
import 'core/theme/theme_provider.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/welcome/presentation/pages/auth_page.dart';
import 'package:provider/provider.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');

void main() async {
  if (isProduction) {
    await _trackVisit(); // ✅ отправляем визит
  }
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies(); // Добавить эту строку

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ImpulseApp(),
    ),
  );
}

Future<void> _trackVisit() async {
  try {
    final request = await html.HttpRequest.request(
      'https://api.impulsepdr.online/api/visit',
      method: 'POST',
      requestHeaders: {
        'Content-Type': 'application/json',
      },
      sendData: '{}',
    );
    print('Visit tracked: ${request.responseText}');
  } catch (e) {
    print('Failed to track visit: $e');
  }
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

class ImpulseApp extends StatelessWidget {
  const ImpulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Impulse',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/home': (context) => HomePage(),
      },
      onGenerateRoute: (settings) {
        // Обработка URL с параметрами
        if (settings.name?.startsWith('/?') ?? false) {
          return MaterialPageRoute(
            builder: (context) => AuthPage(),
            settings: settings,
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, // <-- текущая тема
    );
  }
}
