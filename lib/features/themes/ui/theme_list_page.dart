import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/theme_model.dart';
import 'package:impulse/features/data/theme_repository.dart';
import 'theme_tile.dart';

class ThemeListPage extends StatefulWidget {
  const ThemeListPage({super.key});

  @override
  State<ThemeListPage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemeListPage> {
  late final ThemeRepository _repository;
  late Future<List<ThemeModel>> _themesFuture;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(); // инициализация API клиента
    _repository = ThemeRepository(apiClient: apiClient);
    _themesFuture = _repository.loadThemes(); // получаем темы с API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Темы')),
      body: FutureBuilder<List<ThemeModel>>(
        future: _themesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Темы не найдены'));
          }

          final themes = snapshot.data!;
          return ListView.builder(
            itemCount: themes.length,
            itemBuilder: (context, index) {
              return ThemeTile(theme: themes[index], onTap: () {  },);
            },
          );
        },
      ),
    );
  }
}