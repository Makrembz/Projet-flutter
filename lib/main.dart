import 'package:crub_mini_app/screens/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Services
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/movie_api_service.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/movies/movie_list_screen.dart';
import 'screens/movies/movie_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/favorites_screen.dart';
import 'screens/matching/matching_screen.dart';
import 'screens/admin/admin_panel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<MovieApiService>(create: (_) => MovieApiService()),
      ],
      child: MaterialApp(
        title: 'Movie Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => WelcomeScreen(), // ← Ajoutez cette route
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/movies': (context) => MovieListScreen(),
          '/movie_detail': (context) => MovieDetailScreen(),
          '/profile': (context) => ProfileScreen(),
          '/favorites': (context) => FavoritesScreen(),
          '/matching': (context) => MatchingScreen(),
          '/admin': (context) => AdminPanelScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}