import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/dialog_service.dart'; // Add this import
import '../../models/movie_model.dart';
import '../../models/user_model.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Contrôleurs pour tous les champs du film
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _posterPathController = TextEditingController();
  final TextEditingController _voteAverageController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();

  List<UserModel> _users = [];
  List<MovieModel> _allMovies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showAddMovieForm = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Chargement données admin...');
      final users = await _firestoreService.getAllUsers();
      final movies = await _firestoreService.getMovies();

      setState(() {
        _users = users;
        _allMovies = movies;
        _isLoading = false;
      });

      print('✅ Données chargées: ${_users.length} users, ${_allMovies.length} films');
    } catch (e) {
      print('❌ Erreur chargement: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  Future<void> _addMovie() async {
    // Validation des champs obligatoires
    if (_titleController.text.isEmpty || _overviewController.text.isEmpty) {
      DialogService.showError(
        context,
        'Le titre et la description sont obligatoires',
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Show loading
    final loadingOverlay = DialogService.showLoading(context, 'Ajout du film en cours...');

    try {
      // Conversion des données
      final voteAverage = double.tryParse(_voteAverageController.text) ?? 0.0;
      final releaseDate = _parseReleaseDate(_releaseDateController.text);
      final genres = _parseGenres(_genresController.text);

      final newMovie = MovieModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        overview: _overviewController.text,
        posterPath: _posterPathController.text.isNotEmpty ? _posterPathController.text : null,
        voteAverage: voteAverage,
        releaseDate: releaseDate,
        genres: genres,
        isFromAdmin: true,
      );

      await _firestoreService.addMovie(newMovie);

      // Remove loading
      loadingOverlay.remove();

      // Réinitialiser et cacher le formulaire
      _clearForm();
      _toggleAddMovieForm();
      await _loadData();

      DialogService.showSuccess(
        context,
        'Film ajouté avec succès!',
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      // Remove loading on error
      if (loadingOverlay.mounted) {
        loadingOverlay.remove();
      }

      DialogService.showError(
        context,
        'Erreur lors de l\'ajout du film: $e',
        duration: Duration(seconds: 4),
      );
    }
  }

  Future<void> _deleteMovie(MovieModel movie) async {
    bool confirm = await DialogService.showConfirmation(
      context,
      title: 'Confirmer la suppression',
      message: 'Supprimer le film "${movie.title}" ?',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDangerous: true,
      icon: Icons.delete_forever_rounded,
    );

    if (confirm) {
      final loadingOverlay = DialogService.showLoading(context, 'Suppression en cours...');

      try {
        await _firestoreService.deleteMovie(movie.id);
        await _loadData();

        // Remove loading
        loadingOverlay.remove();

        DialogService.showSuccess(
          context,
          'Film supprimé avec succès',
          duration: Duration(seconds: 2),
        );
      } catch (e) {
        // Remove loading on error
        if (loadingOverlay.mounted) {
          loadingOverlay.remove();
        }

        DialogService.showError(
          context,
          'Erreur lors de la suppression: $e',
          duration: Duration(seconds: 4),
        );
      }
    }
  }

  // Parser la date de sortie
  DateTime _parseReleaseDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Parser les genres
  List<String> _parseGenres(String genresString) {
    if (genresString.isEmpty) return [];
    return genresString.split(',').map((genre) => genre.trim()).toList();
  }

  // Réinitialiser le formulaire
  void _clearForm() {
    _titleController.clear();
    _overviewController.clear();
    _posterPathController.clear();
    _voteAverageController.clear();
    _releaseDateController.clear();
    _genresController.clear();
  }

  // Afficher/Cacher le formulaire d'ajout
  void _toggleAddMovieForm() {
    setState(() {
      _showAddMovieForm = !_showAddMovieForm;
      if (!_showAddMovieForm) {
        _clearForm();
      }
    });
  }

  // Navigation vers les détails du film
  void _navigateToMovieDetails(MovieModel movie) {
    Navigator.pushNamed(
      context,
      '/movie_detail',
      arguments: movie,
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      final updatedUser = UserModel(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        age: user.age,
        photoUrl: user.photoUrl,
        isActive: !user.isActive,
        favoriteMovies: user.favoriteMovies,
        isAdmin: user.isAdmin,
      );

      await _firestoreService.updateUser(updatedUser);

      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });

      DialogService.showSuccess(
        context,
        'Utilisateur ${updatedUser.isActive ? 'activé' : 'désactivé'}',
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      DialogService.showError(
        context,
        'Erreur: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> _toggleAdminStatus(UserModel user) async {
    bool confirm = await DialogService.showConfirmation(
      context,
      title: 'Changer les droits admin',
      message: '${user.isAdmin ? 'Retirer' : 'Donner'} les droits administrateur à ${user.firstName} ${user.lastName}?',
      confirmText: user.isAdmin ? 'Retirer' : 'Donner',
      cancelText: 'Annuler',
      icon: user.isAdmin ? Icons.person_off : Icons.admin_panel_settings,
    );

    if (!confirm) return;

    try {
      final updatedUser = UserModel(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        age: user.age,
        photoUrl: user.photoUrl,
        isActive: user.isActive,
        favoriteMovies: user.favoriteMovies,
        isAdmin: !user.isAdmin,
      );

      await _firestoreService.updateUser(updatedUser);

      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });

      DialogService.showSuccess(
        context,
        'Droits admin ${updatedUser.isAdmin ? 'accordés' : 'retirés'}',
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      DialogService.showError(
        context,
        'Erreur: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    bool confirm = await DialogService.showConfirmation(
      context,
      title: 'Désactiver l\'utilisateur',
      message: 'Désactiver l\'utilisateur ${user.firstName} ${user.lastName} ?\nIl ne pourra plus se connecter.',
      confirmText: 'Désactiver',
      cancelText: 'Annuler',
      isDangerous: true,
      icon: Icons.person_off_rounded,
    );

    if (confirm) {
      final loadingOverlay = DialogService.showLoading(context, 'Désactivation en cours...');

      try {
        final updatedUser = UserModel(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          age: user.age,
          photoUrl: user.photoUrl,
          isActive: false,
          favoriteMovies: user.favoriteMovies,
          isAdmin: user.isAdmin,
        );

        await _firestoreService.updateUser(updatedUser);
        await _loadData();

        // Remove loading
        loadingOverlay.remove();

        DialogService.showSuccess(
          context,
          'Utilisateur désactivé',
          duration: Duration(seconds: 2),
        );
      } catch (e) {
        // Remove loading on error
        if (loadingOverlay.mounted) {
          loadingOverlay.remove();
        }

        DialogService.showError(
          context,
          'Erreur: $e',
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrateur'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des données...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Header avec stats
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade50,
                    Colors.purple.shade50,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Utilisateurs', _users.length, Icons.people, Colors.deepPurple),
                  _buildStatCard('Films Total', _allMovies.length, Icons.movie, Colors.purple),
                  _buildStatCard('Util. Actifs', _users.where((u) => u.isActive).length, Icons.check_circle, Colors.green),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    icon: Icon(Icons.people_alt_rounded),
                    text: 'Utilisateurs',
                  ),
                  Tab(
                    icon: Icon(Icons.movie_creation_rounded),
                    text: 'Films (${_allMovies.length})',
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildUsersTab(),
                  _buildMoviesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Text(
                'Gestion des Utilisateurs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total: ${_users.length}',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _users.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Aucun utilisateur',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Les utilisateurs apparaîtront ici après inscription',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.only(bottom: 16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: user.isAdmin
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: user.isAdmin ? Colors.amber.shade700 : Colors.blue.shade700,
                      ),
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
                          Expanded(
                            child: Text(
                              '${user.firstName} ${user.lastName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (user.isAdmin)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${user.age} ans • ${user.favoriteMovies.length} favoris',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Status indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: user.isActive
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isActive ? Icons.check_circle : Icons.block,
                    size: 14,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 6),
                  Text(
                    user.isActive ? 'Compte actif' : 'Compte désactivé',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.isActive ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(user.isActive ? 'Désactiver' : 'Activer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isActive
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      foregroundColor: user.isActive ? Colors.red : Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAdminStatus(user),
                    icon: Icon(
                      user.isAdmin ? Icons.person_off : Icons.admin_panel_settings,
                      size: 16,
                    ),
                    label: Text(user.isAdmin ? 'Retirer Admin' : 'Donner Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isAdmin
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      foregroundColor: user.isAdmin ? Colors.orange : Colors.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteUser(user),
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Désactiver l\'utilisateur',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildMoviesTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bouton pour afficher/cacher le formulaire
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleAddMovieForm,
                    icon: Icon(_showAddMovieForm ? Icons.visibility_off : Icons.add_circle_outline),
                    label: Text(_showAddMovieForm ? 'Cacher le Formulaire' : 'Ajouter un Film'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showAddMovieForm ? Colors.grey.shade400 : Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Formulaire d'ajout (seulement si _showAddMovieForm = true)
          if (_showAddMovieForm)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.add_circle, color: Colors.green),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Ajouter un Nouveau Film',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre du film *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        prefixIcon: Icon(Icons.title, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _overviewController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        prefixIcon: Icon(Icons.description, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _posterPathController,
                      decoration: InputDecoration(
                        labelText: 'URL de l\'affiche (optionnel)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        prefixIcon: Icon(Icons.image, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _voteAverageController,
                      decoration: InputDecoration(
                        labelText: 'Note moyenne (0-10)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        prefixIcon: Icon(Icons.star, color: Colors.amber),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _releaseDateController,
                      decoration: InputDecoration(
                        labelText: 'Date de sortie (YYYY-MM-DD)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _genresController,
                      decoration: InputDecoration(
                        labelText: 'Genres (séparés par des virgules)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        prefixIcon: Icon(Icons.category, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _toggleAddMovieForm,
                            child: Text('Annuler'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addMovie,
                            icon: Icon(Icons.add_circle, size: 20),
                            label: Text('Ajouter le Film'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // En-tête de la liste
          Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Text(
                  'Films dans la Base de Données',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_allMovies.length} films',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des films
          _allMovies.isEmpty
              ? Container(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Column(
              children: [
                Icon(Icons.movie_creation_outlined, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Aucun film dans la base',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Utilisez le bouton "Ajouter un Film" pour commencer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 16),
            itemCount: _allMovies.length,
            itemBuilder: (context, index) {
              final movie = _allMovies[index];
              return _buildMovieCard(movie);
            },
          ),
        ],
      ),
    );
  }

  // NOUVELLE MÉTHODE : Carte de film cliquable
  Widget _buildMovieCard(MovieModel movie) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToMovieDetails(movie),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Affiche du film
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: movie.posterPath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.posterPath!,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.movie, color: Colors.grey[400], size: 30),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Icon(Icons.movie, color: Colors.grey[400], size: 30),
                ),
              ),

              SizedBox(width: 12),

              // Informations du film
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (movie.isFromAdmin)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4),

                    Text(
                      movie.overview.length > 80
                          ? '${movie.overview.substring(0, 80)}...'
                          : movie.overview,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        // Note
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '${movie.voteAverage.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 12),

                        // Date
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '${movie.releaseDate.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bouton de suppression
              IconButton(
                onPressed: () => _deleteMovie(movie),
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red),
                tooltip: 'Supprimer le film',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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