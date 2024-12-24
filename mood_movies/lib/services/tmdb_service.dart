import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  final String _apiKey = 'a2e87f73c64d8672013cef79244779eb';
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _language = 'tr-TR';

  Future<List<dynamic>> getMoodMovies(String mood) async {
    final Map<String, String> moodGenres = {
      'Mutlu': '35,10751', // Comedy, Family
      'Üzgün': '18,10749', // Drama, Romance
      'Heyecanlı': '28,12', // Action, Adventure
      'Sakin': '16,14', // Animation, Fantasy
      'Düşünceli': '99,36', // Documentary, History
    };

    final genres = moodGenres[mood];
    if (genres == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=$_language&sort_by=popularity.desc&with_genres=$genres&vote_count.gte=50&include_adult=false',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isEmpty) {
          print('No movies found for mood: $mood with genres: $genres');
        }
        return results;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error getting mood movies: $e');
    }
    return [];
  }

  Future<List<dynamic>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&language=$_language&query=${Uri.encodeComponent(query)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    }
    return [];
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=$_language',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  Future<List<dynamic>> getWatchProviders(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/$movieId/watch/providers?api_key=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      if (results != null && results['TR'] != null) {
        final trData = results['TR'];
        if (trData['flatrate'] != null) {
          return trData['flatrate'];
        }
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> getMovieVideos(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      
      // Önce Türkçe fragmanı ara
      final trTrailer = results.firstWhere(
        (video) => 
          video['type'] == 'Trailer' && 
          video['site'] == 'YouTube' &&
          video['iso_639_1'] == 'tr',
        orElse: () => null,
      );

      if (trTrailer != null) return trTrailer;

      // Türkçe yoksa İngilizce fragmanı ara
      final enTrailer = results.firstWhere(
        (video) => 
          video['type'] == 'Trailer' && 
          video['site'] == 'YouTube' &&
          video['iso_639_1'] == 'en',
        orElse: () => null,
      );

      if (enTrailer != null) return enTrailer;

      // Hiçbiri yoksa herhangi bir fragmanı döndür
      final anyTrailer = results.firstWhere(
        (video) => 
          video['type'] == 'Trailer' && 
          video['site'] == 'YouTube',
        orElse: () => {},
      );

      return anyTrailer;
    }
    return {};
  }

  Future<List<dynamic>> getSimilarMovies(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/$movieId/similar?api_key=$_apiKey&language=$_language',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    }
    return [];
  }
}
