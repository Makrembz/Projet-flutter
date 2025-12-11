import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/dialog_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _photoUrlController;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _photoUrlController = TextEditingController(text: widget.user.photoUrl ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final firestoreService = context.read<FirestoreService>();

      // Mettre à jour le profil
      await firestoreService.updateUserProfile(
        userId: widget.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        photoUrl: _photoUrlController.text.trim().isEmpty 
            ? null 
            : _photoUrlController.text.trim(),
      );

      // Petit délai pour s'assurer que Firestore a bien enregistré
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        DialogService.showSuccess(context, 'Profil mis à jour avec succès');

        // Retour avec succès - le StreamBuilder se mettra à jour automatiquement
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        DialogService.showError(context, 'Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Le prénom est requis');
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _showError('Le nom est requis');
      return false;
    }

    if (_ageController.text.trim().isEmpty) {
      _showError('L\'âge est requis');
      return false;
    }

    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 13 || age > 150) {
      _showError('L\'âge doit être entre 13 et 150');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    DialogService.showError(context, message);
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        padding: EdgeInsets.zero,
                      ),
                      Text(
                        'Modifier le profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Photo de profil actuelle
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: widget.user.photoUrl != null
                            ? Image.network(
                                widget.user.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Color(0xFF667eea),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Formulaire
                  Container(
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
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prénom
                        _buildFormField(
                          label: 'Prénom',
                          controller: _firstNameController,
                          icon: Icons.person_outline,
                          isDark: isDark,
                          hint: 'Entrez votre prénom',
                        ),
                        SizedBox(height: 20),

                        // Nom
                        _buildFormField(
                          label: 'Nom',
                          controller: _lastNameController,
                          icon: Icons.person_outline,
                          isDark: isDark,
                          hint: 'Entrez votre nom',
                        ),
                        SizedBox(height: 20),

                        // Âge
                        _buildFormField(
                          label: 'Âge',
                          controller: _ageController,
                          icon: Icons.cake_outlined,
                          isDark: isDark,
                          hint: 'Entrez votre âge',
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                        ),
                        SizedBox(height: 20),

                        // URL de la photo
                        _buildFormField(
                          label: 'URL de la photo de profil (optionnel)',
                          controller: _photoUrlController,
                          icon: Icons.image_outlined,
                          isDark: isDark,
                          hint: 'https://...',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isSaving 
                                ? null 
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: Colors.green.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Sauvegarder',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Informations utiles
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Assurez-vous que l\'URL de votre photo est valide et accessible',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(
              icon,
              color: Color(0xFF667eea),
              size: 20,
            ),
            filled: true,
            fillColor: isDark 
                ? Color(0xFF1a1a2e).withOpacity(0.3)
                : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '',
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
