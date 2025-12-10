import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      return await _getUserFromFirebase(result.user!);
    } catch (e) {
      print('Erreur connexion: $e');
      return null;
    }
  }

  // Inscription - MODIFIÉ POUR GÉRER MIEUX LA PHOTO
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
    String? photoUrl,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // Créer un map des données utilisateur
      Map<String, dynamic> userData = {
        'id': result.user!.uid,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'isActive': true,
        'favoriteMovies': [],
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Ajouter photoUrl seulement si elle n'est pas null
      if (photoUrl != null && photoUrl.isNotEmpty) {
        userData['photoUrl'] = photoUrl;
        print('✅ Photo URL ajoutée aux données: $photoUrl');
      } else {
        print('ℹ️ Aucune photo URL fournie, utilisateur créé sans photo');
      }

      // Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userData);

      // Retourner l'utilisateur créé
      return UserModel(
        id: result.user!.uid,
        firstName: firstName,
        lastName: lastName,
        age: age,
        photoUrl: photoUrl,
      );
    } catch (e) {
      print('❌ Erreur inscription: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer utilisateur depuis Firebase
  Future<UserModel?> _getUserFromFirebase(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Ajouter l'ID manuellement
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('❌ Erreur _getUserFromFirebase: $e');
      return null;
    }
  }

  // Écouter les changements d'authentification ET les changements Firestore
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().switchMap((user) {
      if (user != null) {
        // Écouter les changements en temps réel depuis Firestore
        return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return UserModel.fromMap(data);
          }
          return null;
        });
      }
      return Stream.value(null);
    });
  }

  // MÉTHODE AJOUTÉE: Mettre à jour la photo de profil
  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Photo de profil mise à jour pour $userId');
    } catch (e) {
      print('❌ Erreur updateProfilePhoto: $e');
      rethrow;
    }
  }
}