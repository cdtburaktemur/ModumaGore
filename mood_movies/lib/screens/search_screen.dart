import 'package:flutter/cupertino.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TMDBService _tmdbService = TMDBService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _tmdbService.searchMovies(query);
      setState(() => _searchResults = results);
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Film Ara'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Film adı girin',
                onChanged: (value) => _performSearch(value),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Text('Film aramak için yukarıdaki kutuya yazın'),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MovieDetailScreen(
                                      movieId: movie['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    if (movie['poster_path'] != null)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                          width: 80,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const SizedBox(
                                              width: 80,
                                              height: 120,
                                              child: Center(
                                                child: CupertinoActivityIndicator(),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) =>
                                              const SizedBox(
                                            width: 80,
                                            height: 120,
                                            child: Icon(
                                              CupertinoIcons.photo,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie['title'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (movie['release_date'] != null &&
                                                movie['release_date'].isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  movie['release_date']
                                                      .split('-')[0],
                                                  style: const TextStyle(
                                                    color:
                                                        CupertinoColors.systemGrey,
                                                  ),
                                                ),
                                              ),
                                            if (movie['vote_average'] != null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      CupertinoIcons.star_fill,
                                                      size: 16,
                                                      color: CupertinoColors
                                                          .systemYellow,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      movie['vote_average']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
