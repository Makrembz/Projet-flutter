import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/user_card.dart';
import 'package:provider/provider.dart';

class MatchingScreen extends StatefulWidget {
  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  bool _initialLoadComplete = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print('🎬 MatchingScreen initState called');

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches(UserModel? currentUser) async {
    print('🔄 _loadMatches called with user: ${currentUser?.id}');

    if (currentUser == null) {
      print('❌ Current user is null');
      setState(() {
        _isLoading = false;
        _initialLoadComplete = true;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📡 Fetching all users from Firestore...');
      final allUsers = await _firestoreService.getAllUsers();
      print('✅ Got ${allUsers.length} users from Firestore');

      print('🔍 Current user ${currentUser.firstName} has ${currentUser.favoriteMovies.length} favorite movies');
      if (currentUser.favoriteMovies.isNotEmpty) {
        print('🎬 Favorite movies: ${currentUser.favoriteMovies}');
      }

      final matches = _findMatches(currentUser, allUsers);
      print('🎯 Found ${matches.length} matches');

      setState(() {
        _matches = matches;
        _isLoading = false;
        _initialLoadComplete = true;
      });

      // Démarrer l'animation une fois les données chargées
      _animationController.forward();

      // Debug: print all matches
      if (matches.isNotEmpty) {
        print('📊 Match Details:');
        for (var match in matches) {
          final user = match['user'] as UserModel;
          print('   👤 ${user.firstName} ${user.lastName} - ${match['matchRate'].toStringAsFixed(1)}% (${match['commonMovies'].length} common movies)');
        }
      } else {
        print('ℹ️ No matches found. Reasons could be:');
        print('   - Current user has no favorite movies');
        print('   - Other users have no favorite movies');
        print('   - No common favorite movies with other users');
        print('   - Other users are not active');

        // Debug: Check all users
        print('👥 All users in system:');
        for (var user in allUsers) {
          if (user.id != currentUser.id && user.isActive) {
            print('   ${user.firstName}: ${user.favoriteMovies.length} favorite movies');
          }
        }
      }
    } catch (e, stackTrace) {
      print('💥 ERROR in _loadMatches: $e');
      print('📋 Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _initialLoadComplete = true;
      });
    }
  }

  List<Map<String, dynamic>> _findMatches(UserModel currentUser, List<UserModel> allUsers) {
    final matches = <Map<String, dynamic>>[];
    const double threshold = 75; // Set to 0% to see ALL users initially

    for (final user in allUsers) {
      // Skip current user and inactive users
      if (user.id == currentUser.id || !user.isActive) {
        continue;
      }

      final matchRate = _calculateMatchRate(currentUser.favoriteMovies, user.favoriteMovies);

      print('   Comparing with ${user.firstName}: ${matchRate.toStringAsFixed(1)}% match (${user.favoriteMovies.length} fav movies)');

      if (matchRate >= threshold) {
        matches.add({
          'user': user,
          'matchRate': matchRate,
          'commonMovies': _getCommonMovies(currentUser.favoriteMovies, user.favoriteMovies),
        });
      }
    }

    // Sort by match rate (highest first)
    matches.sort((a, b) => b['matchRate'].compareTo(a['matchRate']));
    return matches;
  }

  double _calculateMatchRate(List<String> user1Movies, List<String> user2Movies) {
    // If both have no movies, return 0
    if (user1Movies.isEmpty && user2Movies.isEmpty) return 0.0;

    // If only one has movies, return 0
    if (user1Movies.isEmpty || user2Movies.isEmpty) return 0.0;

    final commonMovies = user1Movies.toSet().intersection(user2Movies.toSet());
    final totalUniqueMovies = user1Movies.toSet().union(user2Movies.toSet());

    return (commonMovies.length / totalUniqueMovies.length) * 100;
  }

  List<String> _getCommonMovies(List<String> user1Movies, List<String> user2Movies) {
    return user1Movies.toSet().intersection(user2Movies.toSet()).toList();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ MatchingScreen build() called');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        print('📊 StreamBuilder connection state: ${snapshot.connectionState}');
        print('📊 StreamBuilder has data: ${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Waiting for auth stream...');
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                    Color(0xFF402E7A),
                    Color(0xFF4C3BCF),
                    Color(0xFF4B70F5),
                    Color(0xFF3DC2EC),
                  ]
                      : [
                    Color(0xFF402E7A),
                    Color(0xFF4C3BCF),
                    Color(0xFF4B70F5),
                    Color(0xFF3DC2EC),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, isDark, null),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Chargement...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('❌ Stream error: ${snapshot.error}');
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                      : [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, isDark, null),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Erreur de chargement',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final currentUser = snapshot.data;
        print('👤 Current user from stream: ${currentUser?.firstName ?? "null"}');

        if (currentUser == null) {
          print('🚫 No user logged in');
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                      : [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, isDark, null),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Veuillez vous connecter',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Load matches on first build
        if (!_initialLoadComplete) {
          print('🚀 Initial load not complete, triggering loadMatches');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🎬 Post-frame callback executing...');
            _loadMatches(currentUser);
          });
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                    : [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isDark, currentUser),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState(currentUser)
                        : _matches.isEmpty
                        ? _buildEmptyState(context, currentUser)
                        : FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildMatchesList(context, isDark, currentUser),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, UserModel? currentUser) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
          ),
          SizedBox(width: 16),
          // Title with icon
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matching',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (!_isLoading && _matches.isNotEmpty)
                      Text(
                        '${_matches.length} correspondance${_matches.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Refresh button
          if (currentUser != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () {
                  print('🔄 Manual refresh triggered');
                  setState(() {
                    _initialLoadComplete = false;
                    _matches = [];
                    _animationController.reset();
                  });
                  _loadMatches(currentUser);
                },
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(UserModel currentUser) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Recherche de correspondances...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.movie_outlined, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  '${currentUser.favoriteMovies.length} films favoris',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, UserModel currentUser) {
    // Démarrer l'animation si pas déjà en cours
    if (_animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
    }

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty icon with gradient background
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 70,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),

            // Title
            Text(
              'Aucun match trouvé',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 12),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                currentUser.favoriteMovies.isEmpty
                    ? 'Ajoutez des films à vos favoris pour trouver des correspondances avec d\'autres cinéphiles'
                    : 'Essayez d\'ajouter plus de films à vos favoris pour augmenter vos chances de trouver des correspondances',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Retry button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _loadMatches(currentUser),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Réessayer',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Browse movies button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/movies');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.movie_outlined, color: Color(0xFF667eea), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Parcourir',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList(BuildContext context, bool isDark, UserModel currentUser) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF0f0f1e) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle indicator
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with stats
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                // Match count badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_matches.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  _matches.length > 1 ? 'Correspondances' : 'Correspondance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Spacer(),
                // Favorites count chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Color(0xFF667eea).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: isDark ? Colors.white70 : Color(0xFF667eea),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${currentUser.favoriteMovies.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Matches list
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: UserCard(
                      user: match['user'],
                      matchRate: match['matchRate'],
                      commonMoviesCount: match['commonMovies'].length,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}