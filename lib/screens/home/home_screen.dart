import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../services/dialog_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: Provider.of<AuthService>(context).userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'Utilisateur non connecté',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF667eea),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    // App Bar personnalisé
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Header avec logo et actions
                            Row(
                              children: [
                                // Logo stremio
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.movie_outlined,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stremio',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.3),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // Badge Admin
                                if (user.isAdmin)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.amber,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.admin_panel_settings,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'ADMIN',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(width: 8),
                                // Bouton déconnexion
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final confirmed =
                                          await DialogService.showConfirmation(
                                            context,
                                            title: 'Déconnexion',
                                            message:
                                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                                            confirmText: 'Déconnexion',
                                            cancelText: 'Annuler',
                                            isDangerous: false,
                                            icon: Icons.logout,
                                            confirmColor: Colors.red,
                                          );

                                      if (confirmed == true) {
                                        await Provider.of<AuthService>(
                                          context,
                                          listen: false,
                                        ).signOut();
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/login',
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),

                            // Carte de bienvenue
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Color(0xFF2d2d44)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: user.isAdmin
                                            ? [Colors.amber, Colors.orange]
                                            : [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                      ),
                                      border: Border.all(
                                        color: user.isAdmin
                                            ? Colors.amber
                                            : Color(0xFF667eea),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (user.isAdmin
                                                      ? Colors.amber
                                                      : Color(0xFF667eea))
                                                  .withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: user.photoUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              user.photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      user.isAdmin
                                                          ? Icons
                                                                .admin_panel_settings
                                                          : Icons.person,
                                                      size: 35,
                                                      color: Colors.white,
                                                    );
                                                  },
                                            ),
                                          )
                                        : Icon(
                                            user.isAdmin
                                                ? Icons.admin_panel_settings
                                                : Icons.person,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bonjour,',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${user.firstName} ${user.lastName}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          user.isAdmin
                                              ? 'Panel d\'administration'
                                              : 'Prêt pour de nouvelles découvertes ?',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: user.isAdmin
                                                ? Colors.amber
                                                : (isDark
                                                      ? Color(
                                                          0xFF667eea,
                                                        ).withOpacity(0.8)
                                                      : Color(0xFF667eea)),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section fonctionnalités
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 32),
                            Text(
                              user.isAdmin ? 'Gestion' : 'Explorer',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Grille des cartes
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        delegate: SliverChildListDelegate(
                          _buildMenuCards(context, user, isDark),
                        ),
                      ),
                    ),

                    // Section découverte (pour utilisateurs normaux)
                    if (!user.isAdmin)
                      SliverPadding(
                        padding: EdgeInsets.all(24),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xFF2d2d44) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF667eea,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.people_alt_outlined,
                                        color: Color(0xFF667eea),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Communauté',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Découvrez des cinéphiles qui partagent vos passions et trouvez votre match cinéma parfait grâce à notre système intelligent.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/matching');
                                    },
                                    icon: Icon(Icons.search),
                                    label: Text('Trouver des matches'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF667eea),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuCards(
    BuildContext context,
    UserModel user,
    bool isDark,
  ) {
    if (user.isAdmin) {
      return [
        _buildMenuCard(
          context,
          'Panel Admin',
          'Gestion complète',
          Icons.admin_panel_settings_outlined,
          Colors.purple,
          Colors.deepPurple,
          '/admin',
          isDark,
        ),
        _buildMenuCard(
          context,
          'Mon Profil',
          'Voir le profil',
          Icons.person_outline,
          Colors.blue,
          Colors.blueAccent,
          '/profile',
          isDark,
        ),
      ];
    }

    return [
      _buildMenuCard(
        context,
        'Films',
        'Explorer',
        Icons.movie_creation_outlined,
        const Color(0xFF402E7A), // Main color
        const Color(0xFF4C3BCF), // Accent color
        '/movies',
        isDark,
      ),
      _buildMenuCard(
        context,
        'Favoris',
        '${user.favoriteMovies.length} films',
        Icons.favorite_outline,
        const Color(0xFF402E7A),
        const Color(0xFF4C3BCF),
        '/favorites',
        isDark,
      ),
      _buildMenuCard(
        context,
        'Matching',
        'Trouver des amis',
        Icons.people_alt_outlined,
        const Color(0xFF402E7A),
        const Color(0xFF4C3BCF),
        '/matching',
        isDark,
      ),
      _buildMenuCard(
        context,
        'Profil',
        'Mon compte',
        Icons.person_outline,
        const Color(0xFF402E7A),
        const Color(0xFF4C3BCF),
        '/profile',
        isDark,
      ),
    ];

  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color1,
    Color color2,
    String route,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Déconnexion'),
          ],
        ),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<AuthService>(context, listen: false).signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
