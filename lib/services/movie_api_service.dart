import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieApiService {
  // TMDB API Configuration
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '1b4f741098187afa86360022c026a2d4'; // Votre clé
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Récupérer les films populaires
  Future<List<MovieModel>> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=fr-FR&page=1'),
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> movies = data['results'] ?? [];

        print('Nombre de films récupérés: ${movies.length}');

        return movies
            .map((movie) => MovieModel.fromTmdb(movie))
            .toList();
      } else {
        throw Exception('Erreur API TMDB: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur API Movies: $e');
      return _getMockMovies(); // Films mock en cas d'erreur
    }
  }

  // Rechercher des films
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query&language=fr-FR&page=1'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> movies = data['results'] ?? [];

        return movies
            .map((movie) => MovieModel.fromTmdb(movie))
            .toList();
      } else {
        throw Exception('Erreur recherche TMDB: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur recherche: $e');
      return _getMockMovies();
    }
  }

  // Récupérer les genres
  Future<Map<int, String>> getGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey&language=fr-FR'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> genres = data['genres'] ?? [];

        Map<int, String> genreMap = {};
        for (var genre in genres) {
          genreMap[genre['id']] = genre['name'];
        }

        return genreMap;
      }
      return {};
    } catch (e) {
      print('Erreur genres: $e');
      return {};
    }
  }

  // Films mock pour tester en cas d'erreur
  List<MovieModel> _getMockMovies() {
    return [
      MovieModel(
        id: '1',
        title: 'The Shawshank Redemption',
        overview: 'Un banquier injustement condamné à la prison à vie trouve du réconfort auprès d\'un autre détenu...',
        posterPath: '/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
        voteAverage: 9.3,
        releaseDate: DateTime(1994, 9, 23),
        genres: ['Drame'],
      ),
      MovieModel(
        id: '2',
        title: 'The Godfather',
        overview: 'Le patriarche d\'une famille mafieuse transmet le contrôle de son empire clandestin à son fils réticent...',
        posterPath: '/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
        voteAverage: 9.2,
        releaseDate: DateTime(1972, 3, 24),
        genres: ['Crime', 'Drame'],
      ),
      MovieModel(
        id: '3',
        title: 'The Dark Knight',
        overview: 'Batman affronte le Joker, un criminel psychotique qui cherche à semer le chaos à Gotham City...',
        posterPath: '/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        voteAverage: 9.0,
        releaseDate: DateTime(2008, 7, 18),
        genres: ['Action', 'Crime', 'Drame'],
      ),
      MovieModel(
        id: '4',
        title: 'Pulp Fiction',
        overview: 'Les vies de deux hommes de main, d\'un boxeur, d\'un gangster et de sa femme s\'entremêlent...',
        posterPath: '/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        voteAverage: 8.9,
        releaseDate: DateTime(1994, 10, 14),
        genres: ['Crime', 'Drame'],
      ),
      MovieModel(
        id: '5',
        title: 'Forrest Gump',
        overview: 'L\'histoire extraordinaire d\'un homme simple qui vit des événements historiques sans le savoir...',
        posterPath: '/h5J4W4veyxMXDMjeNxZI46TsHOb.jpg',
        voteAverage: 8.8,
        releaseDate: DateTime(1994, 7, 6),
        genres: ['Drame', 'Romance'],
      ),
    ];
  }
}