import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
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
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)]
                : [Color(0xFF667eea), Color(0xFF4A148C), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 2),

                // Logo animé
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.movie_creation_outlined,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48),

                // Nom de l'app
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Stremio',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.5),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Votre cinéma de poche',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Découvrez, partagez, vivez le cinéma',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(flex: 3),

                // Boutons d'action
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Bouton Se connecter
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF667eea),
                              elevation: 12,
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Bouton Créer un compte
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
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
                SizedBox(height: 40),

                // Footer
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    '© 2025 Stremio - Tous droits réservés',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}