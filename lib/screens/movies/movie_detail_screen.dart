import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/dialog_service.dart';
import '../../widgets/rating_widget.dart';
import 'package:provider/provider.dart';

class MovieDetailScreen extends StatefulWidget {
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SingleTickerProviderStateMixin {
  late MovieModel movie;
  late FirestoreService firestoreService;
  bool _isFavorite = false;
  String? _currentUserId;
  String? _currentUserName;
  bool _isLoading = false;
  double _userRating = 0.0;
  String? _userReview;
  double _averageRating = 0.0;
  int _totalRatings = 0;
  Map<int, int> _ratingDistribution = {};
  List<Map<String, dynamic>> _allReviews = []; // NEW: Store all reviews
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movie = ModalRoute.of(context)!.settings.arguments as MovieModel;
    _checkIfFavorite();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.userStream.listen((user) {
      if (user != null && mounted) {
        setState(() {
          _currentUserId = user.id;
          _currentUserName = '${user.firstName} ${user.lastName}';
          _isFavorite = user.favoriteMovies.contains(movie.id);
        });
        _loadRatings();
      }
    });
  }

  Future<void> _loadRatings() async {
    try {
      // Charger l'évaluation de l'utilisateur
      if (_currentUserId != null) {
        final userRating = await firestoreService.getUserRating(_currentUserId!, movie.id);
        if (userRating != null && mounted) {
          setState(() {
            _userRating = (userRating['rating'] ?? 0.0).toDouble();
            _userReview = userRating['review'];
          });
        }
      }

      // Charger les statistiques du film
      final stats = await firestoreService.getMovieRatingStats(movie.id);
      if (mounted) {
        setState(() {
          _averageRating = stats['averageRating'] ?? 0.0;
          _totalRatings = stats['totalRatings'] ?? 0;
          _ratingDistribution = stats['distribution'] ?? {};
        });
      }

      // NEW: Load all reviews for this movie
      await _loadAllReviews();
    } catch (e) {
      print('❌ Erreur chargement évaluations: $e');
    }
  }

  // NEW: Method to load all reviews
  Future<void> _loadAllReviews() async {
    try {
      final reviews = await firestoreService.getAllMovieReviews(movie.id);
      if (mounted) {
        setState(() {
          _allReviews = reviews;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement des avis: $e');
    }
  }

  Future<void> _submitRating(double rating) async {
    if (_currentUserId == null) {
      await DialogService.showInfoDialog(
        context,
        title: 'Connexion requise',
        message: 'Veuillez vous connecter pour évaluer ce film.',
        icon: Icons.login,
      );
      return;
    }

    final reviewController = TextEditingController();

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Évaluer le film'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingWidget(
                    rating: rating,
                    readOnly: false,
                    onRatingChanged: (newRating) {
                      rating = newRating;
                    },
                    size: 32,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire (optionnel)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _saveRating(rating, reviewController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Valider'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveRating(double rating, String review) async {
    final loadingOverlay = DialogService.showLoading(context, 'Enregistrement de l\'évaluation...');

    try {
      await firestoreService.rateMovie(
        userId: _currentUserId!,
        movieId: movie.id,
        rating: rating,
        review: review.isEmpty ? null : review,
        userName: _currentUserName ?? 'Utilisateur',
      );

      loadingOverlay.remove();

      DialogService.showSuccess(
        context,
        'Évaluation enregistrée avec succès !',
        duration: Duration(seconds: 2),
      );

      await _loadRatings();
    } catch (e) {
      if (loadingOverlay.mounted) loadingOverlay.remove();
      DialogService.showError(
        context,
        'Erreur lors de l\'enregistrement: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentUserId == null) return;

    if (_isFavorite) {
      final confirm = await DialogService.showConfirmation(
        context,
        title: 'Retirer des favoris',
        message: 'Êtes-vous sûr de vouloir retirer ce film de vos favoris ?',
        confirmText: 'Retirer',
        cancelText: 'Annuler',
        isDangerous: false,
        icon: Icons.heart_broken,
      );

      if (!confirm) return;
    }

    setState(() {
      _isLoading = true;
    });

    final previousState = _isFavorite;
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await firestoreService.addToFavorites(_currentUserId!, movie.id);
        if (mounted) {
          DialogService.showSuccess(context, 'Ajouté aux favoris !');
        }
      } else {
        await firestoreService.removeFromFavorites(_currentUserId!, movie.id);
        if (mounted) {
          DialogService.showSuccess(context, 'Retiré des favoris');
          await _refreshFavoriteStatus();
        }
      }
    } catch (e) {
      setState(() {
        _isFavorite = previousState;
      });
      if (mounted) {
        DialogService.showError(context, 'Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshFavoriteStatus() async {
    try {
      if (_currentUserId == null) return;

      final updatedUser = await firestoreService.getUserById(_currentUserId!);

      if (updatedUser != null && mounted) {
        setState(() {
          _isFavorite = updatedUser.favoriteMovies.contains(movie.id);
        });
      }
    } catch (e) {
      print('❌ Erreur refresh favorite status: $e');
    }
  }

  // NEW: Widget to build a single review card
  Widget _buildReviewCard(Map<String, dynamic> review, bool isDark) {
    final isCurrentUser = review['userId'] == _currentUserId;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark ? Color(0xFF2d2d44) : Colors.blue.shade50)
            : (isDark ? Color(0xFF1a1a2e) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: Color(0xFF667eea), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF667eea),
                      child: Text(
                        review['userName']?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  review['userName'] ?? 'Utilisateur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF667eea),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Vous',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(review['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${review['rating']?.toStringAsFixed(1) ?? '0.0'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review['review'] != null && review['review'].toString().isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review['review'],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW: Helper method to format date
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date inconnue';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else {
        date = timestamp.toDate();
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'Il y a ${difference.inMinutes} min';
        }
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays}j';
      } else if (difference.inDays < 30) {
        return 'Il y a ${(difference.inDays / 7).floor()} sem';
      } else if (difference.inDays < 365) {
        return 'Il y a ${(difference.inDays / 30).floor()} mois';
      } else {
        return 'Il y a ${(difference.inDays / 365).floor()} an${(difference.inDays / 365).floor() > 1 ? 's' : ''}';
      }
    } catch (e) {
      return 'Date inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: isDark ? Color(0xFF0f0f1e) : Colors.grey.shade50,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: isDark ? Color(0xFF1a1a2e) : Color(0xFF667eea),
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                actions: [
                  if (_currentUserId != null)
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(_isFavorite),
                            color: _isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                        onPressed: _isLoading ? null : _toggleFavorite,
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (movie.posterPath != null)
                        Image.network(
                          movie.posterPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark ? Color(0xFF2d2d44) : Colors.grey.shade300,
                              child: Icon(
                                Icons.movie_outlined,
                                size: 100,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: isDark ? Color(0xFF2d2d44) : Colors.grey.shade300,
                          child: Icon(
                            Icons.movie_outlined,
                            size: 100,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              (isDark ? Color(0xFF0f0f1e) : Colors.grey.shade50).withOpacity(0.8),
                              (isDark ? Color(0xFF0f0f1e) : Colors.grey.shade50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 16),

                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      '${movie.voteAverage.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '/10',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Color(0xFF2d2d44)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF667eea),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '${movie.releaseDate.year}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),

                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xFF2d2d44) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF667eea).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        size: 20,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Synopsis',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  movie.overview.isNotEmpty
                                      ? movie.overview
                                      : 'Aucune description disponible pour ce film.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          if (_totalRatings < 0)
                            Column(
                              children: [
                                RatingStatsWidget(
                                  averageRating: _averageRating,
                                  totalRatings: _totalRatings,
                                  distribution: _ratingDistribution,
                                ),
                                SizedBox(height: 24),
                              ],
                            ),

                          if (_currentUserId != null)
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xFF2d2d44) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.star,
                                          size: 20,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        _userRating > 0 ? 'Votre évaluation' : 'Évaluer ce film',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingWidget(
                                        rating: _userRating,
                                        readOnly: false,
                                        onRatingChanged: _submitRating,
                                        size: 32,
                                      ),
                                      if (_userRating > 0)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${_userRating.toStringAsFixed(1)}/10',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_userReview != null && _userReview!.isNotEmpty) ...[
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Votre avis:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _userReview!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark ? Colors.white70 : Colors.grey.shade800,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          SizedBox(height: 24),

                          // NEW: All Reviews Section
                          if (_allReviews.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xFF2d2d44) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF667eea).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.rate_review,
                                          size: 20,
                                          color: Color(0xFF667eea),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Avis des utilisateurs',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF667eea).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${_allReviews.length} avis',
                                          style: TextStyle(
                                            color: Color(0xFF667eea),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  ...(_allReviews.map((review) => _buildReviewCard(review, isDark)).toList()),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                          ],

                          if (_currentUserId != null)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _toggleFavorite,
                                icon: _isLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 24,
                                ),
                                label: Text(
                                  _isLoading
                                      ? 'Chargement...'
                                      : (_isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFavorite ? Colors.red : Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: (_isFavorite ? Colors.red : Color(0xFF667eea))
                                      .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade400,
                                ),
                              ),
                            ),

                          if (_currentUserId == null)
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Connectez-vous pour ajouter ce film à vos favoris',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}