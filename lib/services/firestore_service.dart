import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== UTILISATEURS ====================
  Future<void> updateUserPhoto(String userId, String photoUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': photoUrl,
      });
      print('✅ Photo de profil mise à jour pour user $userId');
    } catch (e) {
      print('❌ Erreur updateUserPhoto: $e');
      rethrow;
    }
  }

  // Mettre à jour les informations de profil
  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required int age,
    String? photoUrl,
  }) async {
    try {
      final updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
      };

      if (photoUrl != null && photoUrl.isNotEmpty) {
        updateData['photoUrl'] = photoUrl;
      }

      await _firestore.collection('users').doc(userId).update(updateData);
      print('✅ Profil utilisateur $userId mis à jour');
    } catch (e) {
      print('❌ Erreur updateUserProfile: $e');
      rethrow;
    }
  }

  // Utilisateurs - AVEC GESTION D'ERREURS COMPLÈTE ET ID CORRECT
  Future<List<UserModel>> getAllUsers() async {
    try {
      print('🔄 Début chargement utilisateurs...');
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      print('📊 ${snapshot.docs.length} documents trouvés dans Firestore');

      List<UserModel> users = [];

      for (var doc in snapshot.docs) {
        try {
          print('🔍 Traitement document: ${doc.id}');
          final userData = doc.data() as Map<String, dynamic>;
          print('📄 Données brutes: $userData');

          // CORRECTION CRITIQUE : Ajouter l'ID du document aux données
          userData['id'] = doc.id;

          final user = UserModel.fromMap(userData);
          users.add(user);

          print('✅ Utilisateur converti: ${user.firstName} ${user.lastName} (ID: ${user.id})');
        } catch (e) {
          print('❌ ERREUR conversion document ${doc.id}: $e');
          print('❌ Stack trace: ${e.toString()}');
          // Continuer avec les autres utilisateurs
        }
      }

      print('🎉 ${users.length} utilisateurs chargés avec succès');
      return users;
    } catch (e) {
      print('💥 ERREUR GLOBALE chargement utilisateurs: $e');
      print('💥 Stack trace: ${e.toString()}');
      return [];
    }
  }

  // Récupérer un utilisateur spécifique
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        // CORRECTION : Ajouter l'ID du document
        userData['id'] = doc.id;
        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      print('❌ Erreur getUserById: $e');
      return null;
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(UserModel user) async {
    try {
      // Créer un map sans l'ID pour Firebase
      final userData = user.toMap();

      // IMPORTANT : S'assurer qu'on n'envoie pas de champ 'id' à Firebase
      // car l'ID est dans la référence du document
      if (userData.containsKey('id')) {
        userData.remove('id');
      }

      await _firestore.collection('users').doc(user.id).update(userData);
      print('✅ Utilisateur ${user.id} mis à jour');
    } catch (e) {
      print('❌ Erreur updateUser: $e');
      rethrow;
    }
  }

  // Désactiver le compte utilisateur
  Future<void> deactivateAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Compte utilisateur $userId désactivé');
    } catch (e) {
      print('❌ Erreur deactivateAccount: $e');
      rethrow;
    }
  }

  // ==================== FILMS ====================

  // Ajouter un film
  Future<void> addMovie(MovieModel movie) async {
    try {
      // Créer un map pour le film
      final movieData = movie.toMap();

      // Si on utilise l'ID du film comme ID de document
      await _firestore.collection('movies').doc(movie.id).set(movieData);
      print('✅ Film ${movie.title} ajouté avec ID: ${movie.id}');
    } catch (e) {
      print('❌ Erreur addMovie: $e');
      rethrow;
    }
  }

  // Récupérer tous les films
  Future<List<MovieModel>> getMovies() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('movies').get();

      List<MovieModel> movies = [];
      for (var doc in snapshot.docs) {
        try {
          final movieData = doc.data() as Map<String, dynamic>;
          // CORRECTION : Ajouter l'ID du document si non présent
          if (!movieData.containsKey('id')) {
            movieData['id'] = doc.id;
          }
          movies.add(MovieModel.fromMap(movieData));
        } catch (e) {
          print('❌ Erreur conversion film ${doc.id}: $e');
        }
      }

      print('✅ ${movies.length} films chargés');
      return movies;
    } catch (e) {
      print('❌ Erreur getMovies: $e');
      return [];
    }
  }

  // Récupérer un film par son ID
  Future<MovieModel?> getMovieById(String movieId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('movies').doc(movieId).get();
      if (doc.exists) {
        final movieData = doc.data() as Map<String, dynamic>;
        // CORRECTION : Ajouter l'ID du document
        movieData['id'] = doc.id;
        return MovieModel.fromMap(movieData);
      }
      return null;
    } catch (e) {
      print('❌ Erreur getMovieById: $e');
      return null;
    }
  }

  // Supprimer un film
  Future<void> deleteMovie(String movieId) async {
    try {
      await _firestore.collection('movies').doc(movieId).delete();
      print('✅ Film $movieId supprimé');
    } catch (e) {
      print('❌ Erreur suppression film: $e');
      rethrow;
    }
  }

  // ==================== FAVORIS ====================

  // Ajouter un film aux favoris
  Future<void> addToFavorites(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteMovies': FieldValue.arrayUnion([movieId])
      });
      print('✅ Favori ajouté pour user $userId');
    } catch (e) {
      print('❌ Erreur addToFavorites: $e');
      rethrow;
    }
  }

  // Retirer un film des favoris
  Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteMovies': FieldValue.arrayRemove([movieId])
      });
      print('✅ Favori retiré pour user $userId');
    } catch (e) {
      print('❌ Erreur removeFromFavorites: $e');
      rethrow;
    }
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  // ==================== RATINGS ====================

  // Ajouter ou mettre à jour une évaluation
  Future<void> rateMovie({
    required String userId,
    required String movieId,
    required double rating,
    String? review,
    required String userName,
  }) async {
    try {
      // Valider la note (1-5)
      if (rating < 1 || rating > 5) {
        throw Exception('La note doit être entre 1 et 5');
      }

      final ratingId = '$userId-$movieId';
      await _firestore.collection('ratings').doc(ratingId).set({
        'id': ratingId,
        'userId': userId,
        'movieId': movieId,
        'rating': rating,
        'review': review,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userName': userName,
      }, SetOptions(merge: true));

      print('✅ Évaluation ajoutée pour le film $movieId par $userId (note: $rating/5)');
    } catch (e) {
      print('❌ Erreur rateMovie: $e');
      rethrow;
    }
  }

  // Récupérer l'évaluation d'un utilisateur pour un film
  Future<Map<String, dynamic>?> getUserRating(String userId, String movieId) async {
    try {
      final ratingId = '$userId-$movieId';
      final doc = await _firestore.collection('ratings').doc(ratingId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Erreur getUserRating: $e');
      return null;
    }
  }

  // Récupérer toutes les évaluations pour un film
  Future<List<Map<String, dynamic>>> getMovieRatings(String movieId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('movieId', isEqualTo: movieId)
          .get();

      // Trier en client side pour éviter les index Firestore
      final ratings = snapshot.docs.map((doc) => doc.data()).toList();
      ratings.sort((a, b) {
        final dateA = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateB = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return ratings;
    } catch (e) {
      print('❌ Erreur getMovieRatings: $e');
      return [];
    }
  }

  // Calculer les statistiques de notation pour un film
  Future<Map<String, dynamic>> getMovieRatingStats(String movieId) async {
    try {
      final ratings = await getMovieRatings(movieId);

      if (ratings.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalRatings': 0,
          'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      double sum = 0;
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var rating in ratings) {
        final ratingValue = (rating['rating'] ?? 0.0).toDouble();
        sum += ratingValue;

        final ratingInt = ratingValue.round().clamp(1, 5);
        distribution[ratingInt] = (distribution[ratingInt] ?? 0) + 1;
      }

      final average = sum / ratings.length;

      print('✅ Stats calculées pour film $movieId: ${average.toStringAsFixed(1)}/5 (${ratings.length} avis)');

      return {
        'averageRating': average,
        'totalRatings': ratings.length,
        'distribution': distribution,
      };
    } catch (e) {
      print('❌ Erreur getMovieRatingStats: $e');
      return {
        'averageRating': 0.0,
        'totalRatings': 0,
        'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }

  // Supprimer une évaluation
  Future<void> deleteRating(String userId, String movieId) async {
    try {
      final ratingId = '$userId-$movieId';
      await _firestore.collection('ratings').doc(ratingId).delete();
      print('✅ Évaluation supprimée pour le film $movieId');
    } catch (e) {
      print('❌ Erreur deleteRating: $e');
      rethrow;
    }
  }

  // Vérifier si la collection users existe et contient des données
  Future<void> checkDatabaseConnection() async {
    try {
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      final moviesSnapshot = await _firestore.collection('movies').limit(1).get();

      print('🔍 Vérification connexion Firestore:');
      print('   - Collection "users": ${usersSnapshot.docs.length} document(s)');
      print('   - Collection "movies": ${moviesSnapshot.docs.length} document(s)');
      print('   - Connecté avec succès!');
    } catch (e) {
      print('🔴 ERREUR Connexion Firestore: $e');
    }
  }
  //===============================REVIEWS=======================================
// Add this method to your FirestoreService class
// In FirestoreService class

  Future<List<Map<String, dynamic>>> getAllMovieReviews(String movieId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ratings')
          .where('movieId', isEqualTo: movieId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'] ?? '',
          'rating': (data['rating'] ?? 0.0).toDouble(),
          'review': data['review'] ?? '',
          'userName': data['userName'] ?? 'Utilisateur',
          'timestamp': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    } catch (e) {
      print('❌ Erreur chargement des avis: $e');
      return [];
    }
  }}