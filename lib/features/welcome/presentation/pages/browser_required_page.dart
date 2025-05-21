import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

const bool isProduction = bool.fromEnvironment('dart.vm.product');

class BrowserRequiredPage extends StatelessWidget {
  const BrowserRequiredPage({super.key});

  final String referralLink = 'https://impulsepdr.online'; // Замените на вашу ссылку

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Посилання скопійовано! Відкрийте його в браузері.'),
        backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    if (isProduction) {
      _trackVisit(); // ✅ отправляем визит
    }
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 72, color: theme.colorScheme.errorContainer),
                const SizedBox(height: 24),
                Text(
                  'Реєстрація через TikTok заборонена платформою Google',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Для реєстрації та повної роботи застосунку, будь ласка, відкрийте посилання у звичайному браузері.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _copyLink(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Скопіювати посилання'),
                ),
                const SizedBox(height: 16),
                Text(
                  referralLink,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}