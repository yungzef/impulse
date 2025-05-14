import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/repositories/theme_repository_impl.dart';
import 'package:impulse/features/themes/presentation/cubit/themes_cubit.dart';
import 'package:impulse/features/themes/widgets/theme_tile.dart';
import 'package:impulse/features/ticket/presentation/pages/ticket_page.dart';

import '../../../../data/models/theme_model.dart';

class ThemeListPage extends StatefulWidget {
  final String? telegramUserId;

  const ThemeListPage({super.key, required this.telegramUserId});

  @override
  State<ThemeListPage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemeListPage> {
  late final ThemesCubit _cubit;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(userId: widget.telegramUserId);
    final repository = ThemeRepository(apiClient: apiClient);
    _cubit = ThemesCubit(repository)..loadThemesWithProgress();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Теми'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cubit.refreshThemes,
          ),
        ],
      ),
      body: BlocBuilder<ThemesCubit, ThemesState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ThemesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ThemesError) {
            return _buildErrorView(state.message);
          } else if (state is ThemesLoaded) {
            return _buildThemesList(state.themes);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildThemesList(List<ThemeModel> themes) {
    if (themes.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async => _cubit.refreshThemes(),
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
                  builder: (context) => TicketPage(
                    title: theme.name,
                    loader: (client) => client.getThemeQuestions(theme.index),
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
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Теми не знайдені',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _cubit.refreshThemes,
            child: const Text('Оновити'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Помилка завантаження',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cubit.refreshThemes,
            child: const Text('Спробувати знову'),
          ),
        ],
      ),
    );
  }
}