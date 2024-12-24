import 'package:flutter/cupertino.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  final String mood;

  const MovieListScreen({super.key, required this.mood});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TMDBService _tmdbService = TMDBService();
  List<dynamic> _movies = [];
  bool _isLoading = true;

  String _getMoodTitle() {
    switch (widget.mood) {
      case 'Mutlu':
        return 'Mutlu Film Önerileri';
      case 'Üzgün':
        return 'Üzgün Film Önerileri';
      case 'Heyecanlı':
        return 'Heyecanlı Film Önerileri';
      case 'Sakin':
        return 'Sakin Film Önerileri';
      case 'Düşünceli':
        return 'Düşünceli Film Önerileri';
      default:
        return '${widget.mood} Film Önerileri';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      print('Loading movies for mood: ${widget.mood}'); // Debug log
      final movies = await _tmdbService.getMoodMovies(widget.mood);
      print('Found ${movies.length} movies'); // Debug log
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading movies: $e'); // Debug log
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_getMoodTitle()),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _movies.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.film,
                            size: 64,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Film bulunamadı',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bu ruh hali için film önerisi bulunamadı.\nBaşka bir ruh hali seçmeyi deneyin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey.resolveFrom(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
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
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      movie['overview'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.star_fill,
                                          size: 16,
                                          color: CupertinoColors.systemYellow,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          movie['vote_average'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
