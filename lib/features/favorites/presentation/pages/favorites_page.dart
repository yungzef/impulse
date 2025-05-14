import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impulse/core/config/app_config.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';
import 'package:impulse/features/favorites/presentation/cubit/favorites_cubit.dart';

class FavoritesPage extends StatefulWidget {
  final String? userId;

  const FavoritesPage({super.key, required this.userId});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = FavoritesCubit(ApiClient(userId: widget.userId))..loadFavorites();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Обрані питання',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () => _cubit.loadFavorites(),
          ),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is FavoritesError) {
            return _buildErrorView(context, state.message);
          } else if (state is FavoritesLoaded) {
            return _buildFavoritesList(context, state.favorites);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, List<QuestionModel> favorites) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (favorites.isEmpty) {
      return _buildEmptyView(context);
    }

    return AnimatedList(
      padding: const EdgeInsets.symmetric(vertical: 8),
      initialItemCount: favorites.length,
      itemBuilder: (context, index, animation) {
        final question = favorites[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: _buildQuestionCard(context, question),
        );
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionModel question) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: ExpansionTile(
        title: Text(
          question.question,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        collapsedIconColor: colorScheme.onSurface.withOpacity(0.7),
        iconColor: colorScheme.onSurface.withOpacity(0.7),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (question.image != null && question.image!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${AppConfig.apiBaseUrl}/image?path=${question.image!}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  question.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.star, color: colorScheme.primary),
                      label: Text(
                        'Видалити з обраного',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      onPressed: () => _cubit.toggleFavorite(question),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Помилка завантаження',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _cubit.loadFavorites(),
            child: const Text('Спробувати знову'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 48, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Немає обраних питань',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Додавайте питання до обраного, і вони з\'являться тут',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}