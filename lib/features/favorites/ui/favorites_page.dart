import 'package:flutter/material.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/data/models/question_model.dart';

class FavoritesPage extends StatefulWidget {
  final String? userId;

  const FavoritesPage({super.key, required this.userId});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final ApiClient _client;
  late Future<List<QuestionModel>> _favoritesFuture;
  bool _isLoading = false;
  List<QuestionModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _client = ApiClient(userId: widget.userId);
    _favoritesFuture = _loadFavorites();
  }

  Future<List<QuestionModel>> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _client.getFavoriteQuestions();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
      return favorites;
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки избранного: $e')),
      );
      return [];
    }
  }

  bool _isRefreshing = false;

  Future<void> _refreshFavorites() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final updatedFuture = _loadFavorites();
      setState(() {
        _favoritesFuture = updatedFuture;
      });
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _toggleFavorite(QuestionModel question) async {
    try {
      await _client.removeFromFavorites(question.id);
      setState(() {
        question.isFavorite = false;
      });
      await _refreshFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вопрос удалён из избранного')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранные вопросы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFavorites,
          ),
        ],
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyView();
          }

          final favorites = snapshot.data!;
          return AnimatedList(
            padding: const EdgeInsets.symmetric(vertical: 8),
            initialItemCount: favorites.length,
            itemBuilder: (context, index, animation) {
              final question = favorites[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: _buildQuestionCard(context, question),
              );
            },
          );
        },
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
          Text('Ошибка загрузки', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshFavorites,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_border, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text('Нет избранных вопросов', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Добавляйте вопросы в избранное, и они появятся здесь',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionModel question) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          question.question,
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${AppConfig.apiBaseUrl}/image?path=${question.image!}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(question.explanation, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      label: const Text('Удалить из избранного'),
                      onPressed: () => _toggleFavorite(question),
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
}