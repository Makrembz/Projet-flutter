import 'package:flutter/material.dart';
import '../../services/movie_api_service.dart';
import '../../services/firestore_service.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> with SingleTickerProviderStateMixin {
  final MovieApiService _movieService = MovieApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<MovieModel> _movies = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  String _errorMessage = '';
  bool _moviesAlreadySaved = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadMovies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('🔄 Chargement des films...');

      final firestoreMovies = await _firestoreService.getMovies();
      print('✅ Films Firestore chargés: ${firestoreMovies.length}');

      if (firestoreMovies.isEmpty && !_moviesAlreadySaved) {
        print('📥 Aucun film en base, chargement depuis API...');
        final apiMovies = await _movieService.getPopularMovies();
        print('✅ Films API chargés: ${apiMovies.length}');

        await _saveApiMoviesToFirestore(apiMovies);
        _moviesAlreadySaved = true;

        final updatedFirestoreMovies = await _firestoreService.getMovies();
        setState(() {
          _movies = updatedFirestoreMovies;
        });
      } else {
        setState(() {
          _movies = firestoreMovies;
        });
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      _animationController.forward();
      print('🎬 Total films affichés: ${_movies.length}');

    } catch (e) {
      if (!mounted) return;

      print('❌ Erreur chargement films: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Impossible de charger les films';
      });
    }
  }

  Future<void> _saveApiMoviesToFirestore(List<MovieModel> apiMovies) async {
    try {
      int savedCount = 0;

      for (final movie in apiMovies) {
        final existingMovie = await _firestoreService.getMovieById(movie.id);
        if (existingMovie == null) {
          await _firestoreService.addMovie(movie);
          savedCount++;
          print('💾 Film sauvegardé: ${movie.title}');
        }
      }

      print('✅ $savedCount nouveaux films sauvegardés dans Firestore');
    } catch (e) {
      print('❌ Erreur sauvegarde films API: $e');
    }
  }

  Future<void> _searchMovies() async {
    if (_searchQuery.isEmpty) {
      await _loadMovies();
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('🔍 Recherche: "$_searchQuery"');

      final allMovies = await _firestoreService.getMovies();
      final filteredMovies = allMovies.where((movie) {
        return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      if (filteredMovies.isEmpty) {
        print('🔍 Aucun résultat local, recherche API...');
        final apiResults = await _movieService.searchMovies(_searchQuery);

        await _saveApiMoviesToFirestore(apiResults);

        final updatedMovies = await _firestoreService.getMovies();
        final newFilteredMovies = updatedMovies.where((movie) {
          return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        setState(() {
          _movies = newFilteredMovies;
        });
      } else {
        setState(() {
          _movies = filteredMovies;
        });
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      print('✅ Résultats recherche: ${_movies.length} films');

    } catch (e) {
      if (!mounted) return;

      print('❌ Erreur recherche: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur lors de la recherche';
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _loadMovies();
  }

  Future<void> _forceReloadMovies() async {
    _moviesAlreadySaved = false;
    await _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                : [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personnalisé
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Barre de navigation
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Films',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${_movies.length} film${_movies.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Barre de recherche moderne
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF2d2d44) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un film...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF667eea),
                            size: 24,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: _clearSearch,
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Color(0xFF2d2d44)
                              : Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          if (value.length > 2) {
                            Future.delayed(Duration(milliseconds: 500), () {
                              if (_searchQuery == value) {
                                _searchMovies();
                              }
                            });
                          } else if (value.isEmpty) {
                            _loadMovies();
                          }
                        },
                        onSubmitted: (_) => _searchMovies(),
                      ),
                    ),

                    // Indicateur de résultats
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Résultats pour "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF0f0f1e) : Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _buildContent(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2d2d44) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty ? 'Chargement des films...' : 'Recherche en cours...',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Oups !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loadMovies,
                  icon: Icon(Icons.refresh),
                  label: Text(
                    'Réessayer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Color(0xFF667eea).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchQuery.isEmpty ? Icons.movie_outlined : Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 24),
              Text(
                _searchQuery.isEmpty ? 'Aucun film disponible' : 'Aucun résultat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                _searchQuery.isEmpty
                    ? 'Les films apparaîtront ici une fois chargés'
                    : 'Essayez avec d\'autres mots-clés',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loadMovies,
                    icon: Icon(Icons.refresh),
                    label: Text(
                      'Actualiser',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Color(0xFF667eea).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(16),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: MovieCard(
              movie: movie,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/movie_detail',
                  arguments: movie,
                );
              },
            ),
          );
        },
      ),
    );
  }
}