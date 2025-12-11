// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../services/auth_service.dart';
// // import '../../models/user_model.dart';
// //
// // class ProfileScreen extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<UserModel?>(
// //       stream: Provider.of<AuthService>(context).userStream,
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData) {
// //           return Scaffold(body: Center(child: CircularProgressIndicator()));
// //         }
// //
// //         final user = snapshot.data!;
// //
// //         return Scaffold(
// //           appBar: AppBar(title: Text('Mon Profil')),
// //           body: Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Column(
// //               children: [
// //                 CircleAvatar(
// //                   radius: 50,
// //                   backgroundImage: user.photoUrl != null
// //                       ? NetworkImage(user.photoUrl!)
// //                       : null,
// //                   child: user.photoUrl == null
// //                       ? Icon(Icons.person, size: 50)
// //                       : null,
// //                 ),
// //                 SizedBox(height: 20),
// //                 ListTile(
// //                   leading: Icon(Icons.person),
// //                   title: Text('Nom complet'),
// //                   subtitle: Text('${user.firstName} ${user.lastName}'),
// //                 ),
// //                 ListTile(
// //                   leading: Icon(Icons.cake),
// //                   title: Text('Âge'),
// //                   subtitle: Text('${user.age} ans'),
// //                 ),
// //                 ListTile(
// //                   leading: Icon(Icons.email),
// //                   title: Text('ID Utilisateur'),
// //                   subtitle: Text(user.id),
// //                 ),
// //                 ListTile(
// //                   leading: Icon(Icons.movie),
// //                   title: Text('Films favoris'),
// //                   subtitle: Text('${user.favoriteMovies.length} films'),
// //                   trailing: IconButton(
// //                     icon: Icon(Icons.arrow_forward),
// //                     onPressed: () {
// //                       Navigator.pushNamed(context, '/favorites');
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import '../../services/dialog_service.dart';
// import '../../services/firestore_service.dart';
// import '../../models/user_model.dart';
// import 'edit_profile_screen.dart';

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<UserModel?>(
//       stream: Provider.of<AuthService>(context).userStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data == null) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 60, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'Impossible de charger le profil',
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         final user = snapshot.data!;
//         final isDark = Theme.of(context).brightness == Brightness.dark;

//         return Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: isDark
//                     ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
//                     : [Color(0xFF667eea), Color(0xFF764ba2)],
//               ),
//             ),
//             child: SafeArea(
//               child: SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 20),

//                     // Header avec back button et TNCiné
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 24),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () => Navigator.pop(context),
//                             icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//                             padding: EdgeInsets.zero,
//                           ),
//                           Icon(Icons.movie_outlined, color: Colors.red, size: 28),
//                           SizedBox(width: 12),
//                           Text(
//                             'Profil',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                           Spacer(),
//                           IconButton(
//                             icon: Icon(Icons.edit_outlined, color: Colors.white),
//                             onPressed: () async {
//                               final result = await Navigator.push<bool>(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EditProfileScreen(user: user),
//                                 ),
//                               );
//                               if (result == true) {
//                                 // L'utilisateur sera automatiquement mis à jour via le StreamBuilder
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 32),

//                     // Photo de profil
//                     Stack(
//                       children: [
//                         Container(
//                           width: 140,
//                           height: 140,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: user.photoUrl == null
//                                   ? [Color(0xFF667eea), Color(0xFF764ba2)]
//                                   : [Colors.transparent, Colors.transparent],
//                             ),
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 4,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 20,
//                                 offset: Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: ClipOval(
//                             child: user.photoUrl != null
//                                 ? Image.network(
//                               user.photoUrl!,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey.shade300,
//                                   child: Icon(
//                                     Icons.person,
//                                     size: 60,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 );
//                               },
//                               loadingBuilder: (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress.cumulativeBytesLoaded /
//                                         loadingProgress.expectedTotalBytes!
//                                         : null,
//                                     strokeWidth: 3,
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                   ),
//                                 );
//                               },
//                             )
//                                 : Icon(
//                               Icons.person,
//                               size: 60,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         if (user.isAdmin)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               padding: EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.amber,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 3),
//                               ),
//                               child: Icon(
//                                 Icons.star,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),

//                     // Nom
//                     Text(
//                       '${user.firstName} ${user.lastName}',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       '${user.age} ans',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),

//                     if (user.isAdmin)
//                       Padding(
//                         padding: EdgeInsets.only(top: 8),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.amber.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: Colors.amber, width: 1),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.admin_panel_settings, color: Colors.amber, size: 16),
//                               SizedBox(width: 6),
//                               Text(
//                                 'Administrateur',
//                                 style: TextStyle(
//                                   color: Colors.amber,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                     SizedBox(height: 32),

//                     // Carte des informations
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 24),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: isDark ? Color(0xFF2d2d44) : Colors.white,
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 30,
//                               offset: Offset(0, 15),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             _buildInfoTile(
//                               icon: Icons.movie_outlined,
//                               title: 'Films favoris',
//                               subtitle: '${user.favoriteMovies.length} films',
//                               onTap: () {
//                                 Navigator.pushNamed(context, '/favorites');
//                               },
//                               isDark: isDark,
//                               showArrow: true,
//                             ),
//                             Divider(height: 1, indent: 72, endIndent: 24),
//                             _buildInfoTile(
//                               icon: Icons.badge_outlined,
//                               title: 'ID Utilisateur',
//                               subtitle: user.id.length > 20
//                                   ? '${user.id.substring(0, 20)}...'
//                                   : user.id,
//                               onTap: null,
//                               isDark: isDark,
//                             ),
//                             Divider(height: 1, indent: 72, endIndent: 24),
//                             _buildInfoTile(
//                               icon: user.isActive
//                                   ? Icons.check_circle_outline
//                                   : Icons.block,
//                               title: 'Statut du compte',
//                               subtitle: user.isActive ? 'Actif' : 'Inactif',
//                               onTap: null,
//                               isDark: isDark,
//                               subtitleColor: user.isActive ? Colors.green : Colors.red,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 24),

//                     // Bouton de désactivation de compte
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 24),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton.icon(
//                           onPressed: () async {
//                             final confirm = await DialogService.showConfirmation(
//                               context,
//                               title: 'Désactiver le compte',
//                               message: 'Êtes-vous sûr de vouloir désactiver votre compte ?\n\nVous ne pourrez plus vous connecter mais vos données seront conservées.',
//                               confirmText: 'Désactiver',
//                               cancelText: 'Annuler',
//                               isDangerous: true,
//                               icon: Icons.person_off_rounded,
//                             );

//                             if (confirm == true) {
//                               final loadingOverlay = DialogService.showLoading(
//                                 context,
//                                 'Désactivation du compte en cours...',
//                               );

//                               try {
//                                 final firestoreService = context.read<FirestoreService>();
//                                 await firestoreService.deactivateAccount(user.id);

//                                 // Remove loading
//                                 loadingOverlay.remove();

//                                 DialogService.showSuccess(
//                                   context,
//                                   'Compte désactivé avec succès',
//                                   duration: Duration(seconds: 2),
//                                 );

//                                 // Attendre un peu avant de déconnecter
//                                 await Future.delayed(Duration(seconds: 1));

//                                 await Provider.of<AuthService>(context, listen: false).signOut();
//                                 Navigator.pushReplacementNamed(context, '/login');
//                               } catch (e) {
//                                 // Remove loading on error
//                                 if (loadingOverlay.mounted) {
//                                   loadingOverlay.remove();
//                                 }

//                                 DialogService.showError(
//                                   context,
//                                   'Erreur lors de la désactivation: $e',
//                                   duration: Duration(seconds: 4),
//                                 );
//                               }
//                             }
//                           },
//                           icon: Icon(Icons.person_off),
//                           label: Text(
//                             'Désactiver le compte',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange.shade600,
//                             foregroundColor: Colors.white,
//                             elevation: 8,
//                             shadowColor: Colors.orange.withOpacity(0.5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16),

//                     // Bouton de déconnexion
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 24),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton.icon(
//                           onPressed: () async {
//                             final confirm = await showDialog<bool>(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: Text('Déconnexion'),
//                                 content: Text('Voulez-vous vraiment vous déconnecter ?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context, false),
//                                     child: Text('Annuler'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context, true),
//                                     style: TextButton.styleFrom(
//                                       foregroundColor: Colors.red,
//                                     ),
//                                     child: Text('Déconnexion'),
//                                   ),
//                                 ],
//                               ),
//                             );

//                             if (confirm == true) {
//                               await Provider.of<AuthService>(context, listen: false).signOut();
//                               Navigator.pushReplacementNamed(context, '/login');
//                             }
//                           },
//                           icon: Icon(Icons.logout),
//                           label: Text(
//                             'Se déconnecter',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade400,
//                             foregroundColor: Colors.white,
//                             elevation: 8,
//                             shadowColor: Colors.red.withOpacity(0.5),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildInfoTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback? onTap,
//     required bool isDark,
//     bool showArrow = false,
//     Color? subtitleColor,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Color(0xFF667eea).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: Color(0xFF667eea),
//                 size: 24,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: isDark
//                           ? Colors.white.withOpacity(0.6)
//                           : Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: subtitleColor ?? (isDark ? Colors.white : Colors.black87),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             if (showArrow)
//               Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: Colors.grey.shade400,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/dialog_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: Provider.of<AuthService>(context).userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Impossible de charger le profil',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data!;
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
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Header avec back button et TNCiné
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            padding: EdgeInsets.zero,
                          ),
                          Icon(Icons.movie_outlined, color: Colors.red, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Profil',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, color: Colors.white),
                            onPressed: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(user: user),
                                ),
                              );
                              if (result == true) {
                                // L'utilisateur sera automatiquement mis à jour via le StreamBuilder
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Photo de profil
                    Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: user.photoUrl == null
                                  ? [Color(0xFF667eea), Color(0xFF764ba2)]
                                  : [Colors.transparent, Colors.transparent],
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: user.photoUrl != null
                                ? Image.network(
                              user.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            )
                                : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (user.isAdmin)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: Icon(
                                Icons.star,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Nom
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${user.age} ans',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    if (user.isAdmin)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.admin_panel_settings, color: Colors.amber, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Administrateur',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 32),

                    // Carte des informations
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
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
                          children: [
                            _buildInfoTile(
                              icon: Icons.movie_outlined,
                              title: 'Films favoris',
                              subtitle: '${user.favoriteMovies.length} films',
                              onTap: () {
                                Navigator.pushNamed(context, '/favorites');
                              },
                              isDark: isDark,
                              showArrow: true,
                            ),
                            Divider(height: 1, indent: 72, endIndent: 24),
                            _buildInfoTile(
                              icon: Icons.badge_outlined,
                              title: 'ID Utilisateur',
                              subtitle: user.id.length > 20
                                  ? '${user.id.substring(0, 20)}...'
                                  : user.id,
                              onTap: null,
                              isDark: isDark,
                            ),
                            Divider(height: 1, indent: 72, endIndent: 24),
                            _buildInfoTile(
                              icon: user.isActive
                                  ? Icons.check_circle_outline
                                  : Icons.block,
                              title: 'Statut du compte',
                              subtitle: user.isActive ? 'Actif' : 'Inactif',
                              onTap: null,
                              isDark: isDark,
                              subtitleColor: user.isActive ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Bouton de désactivation de compte
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await DialogService.showConfirmation(
                              context,
                              title: 'Désactiver le compte',
                              message: 'Êtes-vous sûr de vouloir désactiver votre compte ?\n\nVous ne pourrez plus vous connecter mais vos données seront conservées.',
                              confirmText: 'Désactiver',
                              cancelText: 'Annuler',
                              isDangerous: true,
                              icon: Icons.person_off_rounded,
                            );

                            if (confirm == true) {
                              final loadingOverlay = DialogService.showLoading(
                                context,
                                'Désactivation du compte...',
                              );

                              try {
                                final firestoreService = context.read<FirestoreService>();
                                await firestoreService.deactivateAccount(user.id);

                                loadingOverlay.remove();

                                DialogService.showSuccess(
                                  context,
                                  'Compte désactivé avec succès',
                                  duration: Duration(seconds: 2),
                                );

                                await Future.delayed(Duration(seconds: 1));

                                await Provider.of<AuthService>(context, listen: false).signOut();
                                Navigator.pushReplacementNamed(context, '/login');
                              } catch (e) {
                                if (loadingOverlay.mounted) {
                                  loadingOverlay.remove();
                                }

                                DialogService.showError(
                                  context,
                                  'Erreur lors de la désactivation: $e',
                                  duration: Duration(seconds: 4),
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.person_off),
                          label: Text(
                            'Désactiver le compte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.orange.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Bouton de déconnexion
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await DialogService.showConfirmation(
                              context,
                              title: 'Déconnexion',
                              message: 'Voulez-vous vraiment vous déconnecter ?',
                              confirmText: 'Déconnexion',
                              cancelText: 'Annuler',
                              isDangerous: false,
                              icon: Icons.logout,
                              confirmColor: Colors.red,
                            );

                            if (confirm == true) {
                              await Provider.of<AuthService>(context, listen: false).signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          icon: Icon(Icons.logout),
                          label: Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.red.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
    bool showArrow = false,
    Color? subtitleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(0xFF667eea),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor ?? (isDark ? Colors.white : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}