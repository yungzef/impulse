import 'dart:html' as html;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:impulse/router.dart';
import 'package:impulse/core/config.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/services/api_client.dart';
import 'features/home/ui/main_menu_page.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const ImpulseApp());
}

class ImpulseApp extends StatefulWidget {
  const ImpulseApp({super.key});

  @override
  State<ImpulseApp> createState() => _ImpulseAppState();
}

class _ImpulseAppState extends State<ImpulseApp> {
  String? _telegramInitData;
  String? _telegramUserId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (kIsWeb) {
        await _initTelegramWebApp();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Initialization error: $e');
    }
  }

  Future<void> _initTelegramWebApp() async {
    try {
      final initData = _getTelegramInitData();
      if (initData == null) {
        throw Exception('Telegram init data not available');
      }

      final userId = _extractTelegramUserId(initData);
      if (userId == null) {
        throw Exception('Failed to extract user ID');
      }

      setState(() {
        _telegramInitData = initData;
        _telegramUserId = userId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      rethrow;
    }
  }

  String? _getTelegramInitData() {
    final uri = Uri.base;
    final data = uri.queryParameters['tgWebAppData'] ??
        'query_id%3Ddebug%26user%3D%257B%2522id%2522%253A123456789%252C%2522first_name%2522%253A%2522Dev%2522%257D%26auth_date%3D9999999999%26hash%3Dfake';
    return data;
  }

  String? _extractTelegramUserId(String data) {
    try {
      final decoded = Uri.decodeFull(data); // 1-й уровень
      final userParam = RegExp(r'user=([^&]+)').firstMatch(decoded)?.group(1);
      if (userParam == null) return null;

      final userJsonRaw = Uri.decodeFull(Uri.decodeFull(userParam)); // 2-й и 3-й уровень
      final map = json.decode(userJsonRaw) as Map<String, dynamic>;
      return map['id'].toString();
    } catch (e) {
      debugPrint('Failed to parse telegram user id: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/', // ← ключевой момент
      home: _buildHomeScreen(),
      onGenerateRoute: (settings) => AppRouter.generateRoute(
        settings,
        telegramInitData: _telegramInitData,
        telegramUserId: _telegramUserId,
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeApp,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return MainMenuPage(
      userId: _telegramUserId,
    );
  }
}
