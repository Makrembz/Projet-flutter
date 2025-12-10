import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  String id;
  String userId;
  String movieId;
  double rating; // 1-5
  String? review;
  DateTime createdAt;
  DateTime? updatedAt;
  String userName; // Pour affichage

  RatingModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    this.review,
    required this.createdAt,
    this.updatedAt,
    required this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'rating': rating,
      'review': review,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userName': userName,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      movieId: map['movieId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      review: map['review'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toString()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null),
      userName: map['userName'] ?? 'Utilisateur',
    );
  }
}

class MovieRatingStats {
  double averageRating;
  int totalRatings;
  Map<int, int> ratingDistribution; // rating -> count

  MovieRatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory MovieRatingStats.empty() {
    return MovieRatingStats(
      averageRating: 0.0,
      totalRatings: 0,
      ratingDistribution: {},
    );
  }
}
