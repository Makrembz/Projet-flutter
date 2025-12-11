// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/user_model.dart';
// import '../../services/auth_service.dart';
// import '../../services/firestore_service.dart';
// import '../../models/movie_model.dart';
// import '../../widgets/movie_card.dart';

// class FavoritesScreen extends StatefulWidget {
//   @override
//   _FavoritesScreenState createState() => _FavoritesScreenState();
// }

// class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
//   final FirestoreService _firestoreService = FirestoreService();
//   List<MovieModel> _favoriteMovies = [];
//   bool _isLoading = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 600),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadFavorites(String? userId) async {
//     if (userId == null) {
//       setState(() {
//         _favoriteMovies = [];
//         _isLoading = false;
//       });
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Récupérer l'utilisateur pour avoir ses favoris
//       final user = await _firestoreService.getUserById(userId);

//       if (user == null) {
//         setState(() {
//           _favoriteMovies = [];
//           _isLoading = false;
//         });
//         return;
//       }

//       // Charger tous les films
//       final allMovies = await _firestoreService.getMovies();

//       // Filtrer seulement les films dont l'ID est dans favoriteMovies de l'utilisateur
//       setState(() {
//         _favoriteMovies = allMovies.where((movie) {
//           return user.favoriteMovies.contains(movie.id);
//         }).toList();
//         _isLoading = false;
//       });

//       // Démarrer l'animation une fois les données chargées
//       _animationController.forward();

//       print('✅ ${_favoriteMovies.length} films favoris chargés pour ${user.firstName}');

//     } catch (e) {
//       print('❌ Erreur chargement favoris: $e');
//       setState(() {
//         _favoriteMovies = [];
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return StreamBuilder<UserModel?>(
//       stream: authService.userStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isDark
//                       ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
//                       : [Color(0xFF667eea), Color(0xFF764ba2)],
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     _buildAppBar(context, isDark),
//                     Expanded(
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 80,
//                               height: 80,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 4,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             ),
//                             SizedBox(height: 24),
//                             Text(
//                               'Chargement...',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white70,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }

//         final user = snapshot.data;

//         // Charger les favoris quand l'utilisateur est disponible
//         if (user != null && _favoriteMovies.isEmpty && _isLoading) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             print("user id = " + user.id);
//             _loadFavorites(user.id);
//           });
//         }

//         return Scaffold(
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: isDark
//                     ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
//                     : [Color(0xFF667eea), Color(0xFF764ba2)],
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   _buildAppBar(context, isDark),
//                   Expanded(
//                     child: _isLoading
//                         ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 80,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 4,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Text(
//                             'Chargement de vos favoris...',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white70,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                         : _favoriteMovies.isEmpty
//                         ? _buildEmptyState(context)
//                         : FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: _buildFavoritesList(context, isDark),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAppBar(BuildContext context, bool isDark) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           // Back button
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1,
//               ),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//               padding: EdgeInsets.all(8),
//               constraints: BoxConstraints(),
//             ),
//           ),
//           SizedBox(width: 16),
//           // Title with icon
//           Expanded(
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.favorite_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Mes Favoris',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     if (!_isLoading && _favoriteMovies.isNotEmpty)
//                       Text(
//                         '${_favoriteMovies.length} film${_favoriteMovies.length > 1 ? 's' : ''}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.white70,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Empty icon with gradient background
//             Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.white.withOpacity(0.15),
//                     Colors.white.withOpacity(0.05),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 2,
//                 ),
//               ),
//               child: Icon(
//                 Icons.favorite_border_rounded,
//                 size: 70,
//                 color: Colors.white.withOpacity(0.7),
//               ),
//             ),
//             SizedBox(height: 32),

//             // Title
//             Text(
//               'Aucun film favori',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 0.3,
//               ),
//             ),
//             SizedBox(height: 12),

//             // Description
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 48),
//               child: Text(
//                 'Ajoutez des films à vos favoris pour les retrouver facilement ici',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.white70,
//                   height: 1.5,
//                 ),
//               ),
//             ),
//             SizedBox(height: 32),

//             // Action button
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 12,
//                     offset: Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context); // Retour à l'écran précédent
//                   },
//                   borderRadius: BorderRadius.circular(16),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.movie_outlined, color: Colors.white, size: 22),
//                         SizedBox(width: 10),
//                         Text(
//                           'Découvrir des films',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFavoritesList(BuildContext context, bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? Color(0xFF0f0f1e) : Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(32),
//           topRight: Radius.circular(32),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Handle indicator
//           Container(
//             margin: EdgeInsets.only(top: 12, bottom: 8),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: isDark ? Colors.white24 : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Header with count
//           Padding(
//             padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${_favoriteMovies.length}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   _favoriteMovies.length > 1 ? 'Films favoris' : 'Film favori',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Movies list
//           Expanded(
//             child: ListView.builder(
//               physics: BouncingScrollPhysics(),
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               itemCount: _favoriteMovies.length,
//               itemBuilder: (context, index) {
//                 return TweenAnimationBuilder<double>(
//                   duration: Duration(milliseconds: 400 + (index * 100)),
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   curve: Curves.easeOutCubic,
//                   builder: (context, value, child) {
//                     return Transform.translate(
//                       offset: Offset(0, 20 * (1 - value)),
//                       child: Opacity(
//                         opacity: value,
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 12),
//                     child: MovieCard(
//                       movie: _favoriteMovies[index],
//                       onTap: () {
//                         Navigator.pushNamed(
//                           context,
//                           '/movie_detail',
//                           arguments: _favoriteMovies[index],
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_card.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin, RouteAware {
  final FirestoreService _firestoreService = FirestoreService();
  List<MovieModel> _favoriteMovies = [];
  bool _isLoading = true;
  String? _currentUserId;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites(String? userId) async {
    if (userId == null) {
      setState(() {
        _favoriteMovies = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Récupérer l'utilisateur pour avoir ses favoris
      final user = await _firestoreService.getUserById(userId);

      if (user == null) {
        setState(() {
          _favoriteMovies = [];
          _isLoading = false;
        });
        return;
      }

      // Charger tous les films
      final allMovies = await _firestoreService.getMovies();

      // Filtrer seulement les films dont l'ID est dans favoriteMovies de l'utilisateur
      setState(() {
        _favoriteMovies = allMovies.where((movie) {
          return user.favoriteMovies.contains(movie.id);
        }).toList();
        _isLoading = false;
      });

      // Démarrer l'animation une fois les données chargées
      _animationController.forward();

      print('✅ ${_favoriteMovies.length} films favoris chargés pour ${user.firstName}');

    } catch (e) {
      print('❌ Erreur chargement favoris: $e');
      setState(() {
        _favoriteMovies = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFavorites() async {
    if (_currentUserId != null) {
      // Reset animation for refresh
      _animationController.reset();
      await _loadFavorites(_currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                    _buildAppBar(context, isDark),
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

        final user = snapshot.data;

        // Load favorites when user is available or user ID changes
        if (user != null && user.id != _currentUserId) {
          _currentUserId = user.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print("user id = " + user.id);
            _loadFavorites(user.id);
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
                  _buildAppBar(context, isDark),
                  Expanded(
                    child: _isLoading
                        ? Center(
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
                            'Chargement de vos favoris...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                        : _favoriteMovies.isEmpty
                        ? _buildEmptyState(context)
                        : FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFavoritesList(context, isDark),
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

  Widget _buildAppBar(BuildContext context, bool isDark) {
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
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Favoris',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (!_isLoading && _favoriteMovies.isNotEmpty)
                      Text(
                        '${_favoriteMovies.length} film${_favoriteMovies.length > 1 ? 's' : ''}',
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.favorite_border_rounded,
                size: 70,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),

            // Title
            Text(
              'Aucun film favori',
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
                'Ajoutez des films à vos favoris pour les retrouver facilement ici',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 32),

            // Action button
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
                  onTap: () {
                    Navigator.pop(context); // Retour à l'écran précédent
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_outlined, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Découvrir des films',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
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
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, bool isDark) {
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

          // Header with count
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_favoriteMovies.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  _favoriteMovies.length > 1 ? 'Films favoris' : 'Film favori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Movies list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshFavorites,
              color: Color(0xFF667eea),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _favoriteMovies.length,
                itemBuilder: (context, index) {
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
                      child: MovieCard(
                        movie: _favoriteMovies[index],
                        onTap: () async {
                          // Navigate and wait for result
                          final result = await Navigator.pushNamed(
                            context,
                            '/movie_detail',
                            arguments: _favoriteMovies[index],
                          );
                          
                          // Refresh favorites if something changed
                          if (result == true) {
                            await _refreshFavorites();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}