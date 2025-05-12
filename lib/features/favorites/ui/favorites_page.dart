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
        SnackBar(content: Text('Помилка завантаження обраного: $e')),
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
        const SnackBar(content: Text('Питання видалено з обраного')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text(
          'Обрані питання',
          style: TextStyle(color: Color(0xFFF5F5F5)),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD7FF56)),
            );
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
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
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
          Text(
            'Помилка завантаження',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: const Color(0xFFF5F5F5)),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFE5E5E7)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD7FF56),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _refreshFavorites,
            child: const Text('Спробувати знову'),
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
          Text(
            'Немає обраних питань',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: const Color(0xFFF5F5F5)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Додавайте питання до обраного, і вони з\'являться тут',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFE5E5E7)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionModel question) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: ExpansionTile(
        title: Text(
          question.question,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: const Color(0xFFF5F5F5)),
        ),
        collapsedIconColor: const Color(0xFFE5E5E7),
        iconColor: const Color(0xFFE5E5E7),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE5E5E7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      label: Text(
                        'Видалити з обраного',
                        style: const TextStyle(color: Color(0xFFE5E5E7)),
                      ),
                      onPressed: () {
                        _toggleFavorite(question);
                      },
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
