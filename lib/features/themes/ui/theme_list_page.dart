// lib/features/themes/ui/theme_list_page.dart
import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/theme_model.dart';
import 'package:impulse/features/data/theme_repository.dart';
import 'package:impulse/features/ticket/ui/ticket_page.dart';
import 'theme_tile.dart';

class ThemeListPage extends StatefulWidget {
  final String? telegramUserId;

  const ThemeListPage({super.key, required this.telegramUserId});

  @override
  State<ThemeListPage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemeListPage> {
  late final ThemeRepository _repository;
  late Future<List<ThemeModel>> _themesFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(userId: widget.telegramUserId);
    _repository = ThemeRepository(apiClient: apiClient);
    _themesFuture = _loadThemesWithProgress();
  }

  Future<List<ThemeModel>> _loadThemesWithProgress() async {
    try {
      var themes = await _repository.loadThemes();

      List<ThemeModel> updatedThemes = [];
      for (var theme in themes) {
        final progress = await _repository.loadThemeProgress(theme.index);
        updatedThemes.add(theme.copyWith(
          lastAnsweredIndex: progress['last_question'],
          accuracy: progress['accuracy'],
        ));
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
      return updatedThemes;
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      rethrow;
    }
  }

  Future<void> _refreshThemes() async {
    setState(() => _isLoading = true);
    try {
      final updatedFuture = _loadThemesWithProgress();
      setState(() {
        _themesFuture = updatedFuture;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка оновлення: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Теми'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshThemes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<ThemeModel>>(
        future: _themesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme
                      .of(context)
                      .indicatorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Помилка завантаження тем',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshThemes,
                    child: const Text('Спробувати знову'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 48, color: Theme
                      .of(context)
                      .disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    'Теми не знайдені',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshThemes,
                    child: const Text('Оновити'),
                  ),
                ],
              ),
            );
          }

          final themes = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshThemes,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: themes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final theme = themes[index];
                return ThemeTile(
                  theme: theme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TicketPage(
                              title: theme.name,
                              loader: (client) =>
                                  client.getThemeQuestions(theme.index),
                              telegramUserId: widget.telegramUserId,
                              startFromIndex: theme.lastAnsweredIndex,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}