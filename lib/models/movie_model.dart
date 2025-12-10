class MovieModel {
  String id;
  String title;
  String overview;
  String? posterPath;
  double voteAverage;
  DateTime releaseDate;
  List<String> genres;
  bool isFromAdmin;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    this.genres = const [],
    this.isFromAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate.toIso8601String(),
      'genres': genres,
      'isFromAdmin': isFromAdmin,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'].toString(),
      title: map['title'],
      overview: map['overview'],
      posterPath: map['posterPath'],
      voteAverage: (map['voteAverage'] ?? 0.0).toDouble(),
      releaseDate: DateTime.parse(map['releaseDate']),
      genres: List<String>.from(map['genres'] ?? []),
      isFromAdmin: map['isFromAdmin'] ?? false,
    );
  }

  // Pour TMDB API
  factory MovieModel.fromTmdb(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'].toString(),
      title: map['title'] ?? 'Sans titre',
      overview: map['overview'] ?? 'Pas de description disponible',
      posterPath: map['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${map['poster_path']}'
          : null,
      voteAverage: (map['vote_average'] ?? 0.0).toDouble(),
      releaseDate: map['release_date'] != null && map['release_date'].isNotEmpty
          ? DateTime.parse(map['release_date'])
          : DateTime.now(),
      genres: [], // On pourrait récupérer les genres séparément
      isFromAdmin: false,
    );
  }

  // Pour l'API RapidAPI (garder au cas où)
  factory MovieModel.fromApi(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'].toString(),
      title: map['title'] ?? 'Sans titre',
      overview: map['overview'] ?? 'Pas de description',
      posterPath: map['poster_path'],
      voteAverage: (map['vote_average'] ?? 0.0).toDouble(),
      releaseDate: map['release_date'] != null
          ? DateTime.parse(map['release_date'])
          : DateTime.now(),
      genres: [],
      isFromAdmin: false,
    );
  }

  // Méthode utilitaire pour obtenir l'URL complète de l'image
  String? get fullPosterPath {
    if (posterPath == null) return null;
    if (posterPath!.startsWith('http')) return posterPath;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}