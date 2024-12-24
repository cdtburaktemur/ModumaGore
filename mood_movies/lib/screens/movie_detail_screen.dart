import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TMDBService _tmdbService = TMDBService();
  Map<String, dynamic>? _movieDetails;
  Map<String, dynamic>? _movieTrailer;
  List<dynamic> _watchProviders = [];
  List<dynamic> _similarMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final details = await _tmdbService.getMovieDetails(widget.movieId);
      final providers = await _tmdbService.getWatchProviders(widget.movieId);
      final trailer = await _tmdbService.getMovieVideos(widget.movieId);
      final similar = await _tmdbService.getSimilarMovies(widget.movieId);
      setState(() {
        _movieDetails = details;
        _watchProviders = providers;
        _movieTrailer = trailer;
        _similarMovies = similar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openTrailer() async {
    if (_movieTrailer == null || _movieTrailer!.isEmpty) return;
    
    final videoKey = _movieTrailer!['key'];
    if (videoKey == null) return;

    final url = Uri.parse('https://www.youtube.com/watch?v=$videoKey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Film Detayları'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _movieDetails == null
                ? const Center(child: Text('Film detayları yüklenemedi'))
                : ListView(
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            'https://image.tmdb.org/t/p/w500${_movieDetails!['backdrop_path']}',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                              height: 200,
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 100,
                              ),
                            ),
                          ),
                          if (_movieTrailer != null && _movieTrailer!.isNotEmpty)
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: _openTrailer,
                                child: Container(
                                  color: CupertinoColors.black.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.play_circle_fill,
                                      color: CupertinoColors.white,
                                      size: 64,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _movieDetails!['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.star_fill,
                                  color: CupertinoColors.systemYellow,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _movieDetails!['vote_average'].toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _movieDetails!['release_date'].split('-')[0],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Özet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _movieDetails!['overview'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_watchProviders.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'İzleme Platformları',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _watchProviders.length,
                                  itemBuilder: (context, index) {
                                    final provider = _watchProviders[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            if (_similarMovies.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Benzer Filmler',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _similarMovies.length,
                                  itemBuilder: (context, index) {
                                    final movie = _similarMovies[index];
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
                                        width: 120,
                                        margin: const EdgeInsets.only(right: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                                height: 150,
                                                width: 120,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return const SizedBox(
                                                    height: 150,
                                                    width: 120,
                                                    child: Center(
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              movie['title'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
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
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
