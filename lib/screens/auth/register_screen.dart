import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/dialog_service.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _obscurePassword = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
      Navigator.pop(context); // Close bottom sheet
    } catch (e) {
      print('Error picking image: $e');
      DialogService.showError(
        context,
        'Erreur lors de la sélection de l\'image: ${e.toString()}',
        duration: Duration(seconds: 3),
      );
    }
  }

  void _showImageSourceBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2d2d44) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Choisir une photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galerie',
                    onTap: () => _pickImage(ImageSource.gallery),
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Caméra',
                    onTap: () => _pickImage(ImageSource.camera),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Color(0xFF667eea)),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImageToFirebase(File imageFile, String userId) async {
    try {
      setState(() => _isUploadingImage = true);

      String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      // Add metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toString(),
        },
      );

      // Upload the file
      await storageRef.putFile(imageFile, metadata);

      // Get download URL
      String downloadUrl = await storageRef.getDownloadURL();

      print('✅ Image uploaded successfully: $downloadUrl');
      setState(() => _isUploadingImage = false);
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');

      // Show error to user
      if (mounted) {
        DialogService.showError(
          context,
          'Erreur lors de l\'upload de la photo: ${e.toString()}',
          duration: Duration(seconds: 3),
        );
      }

      setState(() => _isUploadingImage = false);
      return null;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading overlay
    final loadingOverlay = DialogService.showLoading(context, 'Création du compte en cours...');

    setState(() => _isLoading = true);

    try {
      // ÉTAPE 1: Créer l'utilisateur D'ABORD (sans photo)
      print('👤 Création du compte utilisateur...');
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        photoUrl: null, // Créer sans photo d'abord
      );

      if (user == null) {
        throw Exception('Échec de création du compte utilisateur');
      }

      print('✅ Utilisateur créé avec ID: ${user.id}');

      // ÉTAPE 2: Upload de la photo SI elle est sélectionnée
      if (_selectedImage != null && user.id.isNotEmpty) {
        print('📸 Upload de la photo en cours...');

        try {
          // Upload avec le vrai ID utilisateur
          String? photoUrl = await _uploadImageToFirebase(_selectedImage!, user.id);

          if (photoUrl != null && photoUrl.isNotEmpty) {
            print('✅ Photo uploadée avec succès: $photoUrl');

            // Mettre à jour l'utilisateur avec la nouvelle photo
            await _authService.updateProfilePhoto(user.id, photoUrl);

            // Vérification
            await Future.delayed(Duration(milliseconds: 500));
            DocumentSnapshot doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                .get();

            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              print('🔍 Photo sauvegardée dans Firestore: ${data['photoUrl']}');
            }
          } else {
            print('⚠️ Photo uploadée mais URL invalide');
            DialogService.showWarning(
              context,
              'Photo non sauvegardée, mais compte créé avec succès',
              duration: Duration(seconds: 3),
            );
          }
        } catch (e) {
          print('⚠️ Erreur upload photo, mais compte créé: $e');
          DialogService.showWarning(
            context,
            'Photo non sauvegardée, mais compte créé avec succès',
            duration: Duration(seconds: 3),
          );
        }
      } else {
        print('ℹ️ Aucune photo sélectionnée, compte créé sans photo');
      }

      // Remove loading overlay
      loadingOverlay.remove();

      // ÉTAPE 3: Vérification finale
      print('🔍 Vérification finale...');
      await Future.delayed(Duration(seconds: 1));

      DocumentSnapshot finalCheck = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .get();

      if (finalCheck.exists) {
        final data = finalCheck.data() as Map<String, dynamic>;
        print('🎉 Utilisateur final dans Firestore:');
        print('   - ID: ${data['id']}');
        print('   - Nom: ${data['firstName']} ${data['lastName']}');
        print('   - Email: ${_emailController.text}');
        print('   - Photo URL: ${data['photoUrl'] ?? "Aucune"}');
      }

      // ÉTAPE 4: Navigation avec message de succès
      if (mounted) {
        DialogService.showSuccess(
          context,
          'Compte créé avec succès!',
          duration: Duration(seconds: 2),
        );

        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/home');
      }

    } catch (e) {
      print('❌ Erreur d\'inscription: $e');

      // Remove loading overlay on error
      if (loadingOverlay.mounted) {
        loadingOverlay.remove();
      }

      if (mounted) {
        DialogService.showError(
          context,
          'Erreur d\'inscription: ${e.toString()}',
          duration: Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                : [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation ?? AlwaysStoppedAnimation(1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),

                    // Logo / App Name
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.movie_outlined,
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TNCiné',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2),
                              Container(
                                width: 60,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.white.withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Welcome Text
                    Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Rejoignez la communauté TNCiné',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Registration Form Card
                    Container(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Profile Picture Section
                            GestureDetector(
                              onTap: _showImageSourceBottomSheet,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: _selectedImage == null
                                            ? [Color(0xFF667eea), Color(0xFF764ba2)]
                                            : [Colors.transparent, Colors.transparent],
                                      ),
                                      border: Border.all(
                                        color: Color(0xFF667eea),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF667eea).withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: _selectedImage != null
                                        ? ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : Icon(
                                      Icons.person_outline,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_isUploadingImage)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF667eea),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? Color(0xFF2d2d44) : Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedImage == null ? 'Ajouter une photo' : 'Modifier la photo',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedImage != null)
                              TextButton(
                                onPressed: () {
                                  setState(() => _selectedImage = null);
                                },
                                child: Text(
                                  'Supprimer',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            SizedBox(height: 24),

                            // First Name Field
                            TextFormField(
                              controller: _firstNameController,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Prénom',
                                hintText: 'Votre prénom',
                                prefixIcon: Icon(Icons.person_outline),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre prénom';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Last Name Field
                            TextFormField(
                              controller: _lastNameController,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Nom',
                                hintText: 'Votre nom',
                                prefixIcon: Icon(Icons.badge_outlined),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Age Field
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Âge',
                                hintText: 'Votre âge',
                                prefixIcon: Icon(Icons.cake_outlined),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre âge';
                                }
                                final age = int.tryParse(value);
                                if (age == null) {
                                  return 'Âge invalide';
                                }
                                if (age < 13) {
                                  return 'Vous devez avoir au moins 13 ans';
                                }
                                if (age > 120) {
                                  return 'Âge invalide';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'exemple@email.com',
                                prefixIcon: Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Email invalide';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un mot de passe';
                                }
                                if (value.length < 6) {
                                  return 'Mot de passe trop court (min. 6 caractères)';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 28),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading || _isUploadingImage ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: Color(0xFF667eea).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: _isLoading || _isUploadingImage
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      _isUploadingImage ? 'Téléchargement...' : 'Création...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                                    : Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}