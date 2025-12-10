import 'package:cloud_firestore/cloud_firestore.dart'; // AJOUTEZ CET IMPORT

class UserModel {
  String id;
  String firstName;
  String lastName;
  int age;
  String? photoUrl;
  bool isActive;
  List<String> favoriteMovies;
  bool isAdmin;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.photoUrl,
    this.isActive = true,
    this.favoriteMovies = const [],
    this.isAdmin = false,
  });

  // Convertir en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'favoriteMovies': favoriteMovies,
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Créer depuis Firebase - VERSION ULTRA SÉCURISÉE
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    // Si le map est null, retourner un utilisateur par défaut
    if (map == null) {
      return UserModel(
        id: 'default_id',
        firstName: 'Utilisateur',
        lastName: 'Inconnu',
        age: 0,
      );
    }

    try {
      // Conversion sécurisée de chaque champ
      return UserModel(
        id: _convertToString(map['id'], 'default_id'),
        firstName: _convertToString(map['firstName'], 'Utilisateur'),
        lastName: _convertToString(map['lastName'], 'Anonyme'),
        age: _convertToInt(map['age'], 0),
        photoUrl: map['photoUrl']?.toString(),
        isActive: _convertToBool(map['isActive'], true),
        favoriteMovies: _convertToStringList(map['favoriteMovies']),
        isAdmin: _convertToBool(map['isAdmin'], false),
      );
    } catch (e) {
      print('❌ ERREUR CRITIQUE dans UserModel.fromMap: $e');
      // Retourner un utilisateur par défaut en cas d'erreur critique
      return UserModel(
        id: 'error_user',
        firstName: 'Erreur',
        lastName: 'Utilisateur',
        age: 0,
        isActive: false,
      );
    }
  }

  // Helper methods
  static String _convertToString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static int _convertToInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static bool _convertToBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return defaultValue;
  }

  static List<String> _convertToStringList(dynamic value) {
    if (value == null) return [];
    if (value is List<String>) return value;
    if (value is List<dynamic>) {
      try {
        return value.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $firstName $lastName, admin: $isAdmin)';
  }
}