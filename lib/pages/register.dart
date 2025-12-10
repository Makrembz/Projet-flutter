/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Upload image to Firebase Storage et récupérer l'URL
      String? photoUrl;

      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        age: int.parse(_ageController.text),
        photoUrl: photoUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie !'), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade900, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20),

                  // Titre
                  Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Photo de profil
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.white),
                          SizedBox(height: 5),
                          Text(
                            'Ajouter photo',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Nom
                  _buildTextField(
                    controller: _nomController,
                    label: 'Nom',
                    icon: Icons.person,
                    validator: (value) => value!.isEmpty ? 'Entrez votre nom' : null,
                  ),
                  SizedBox(height: 16),

                  // Prénom
                  _buildTextField(
                    controller: _prenomController,
                    label: 'Prénom',
                    icon: Icons.person_outline,
                    validator: (value) => value!.isEmpty ? 'Entrez votre prénom' : null,
                  ),
                  SizedBox(height: 16),

                  // Âge
                  _buildTextField(
                    controller: _ageController,
                    label: 'Âge',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Entrez votre âge';
                      if (int.tryParse(value) == null) return 'Âge invalide';
                      if (int.parse(value) < 13) return 'Vous devez avoir au moins 13 ans';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Entrez votre email';
                      if (!value.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Mot de passe
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Entrez un mot de passe';
                      if (value.length < 6) return 'Au moins 6 caractères';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Confirmer mot de passe
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer mot de passe',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  // Bouton S'inscrire
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Retour à la connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}*/