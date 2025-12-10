// import 'package:flutter/material.dart';

// /// Service pour afficher des overlays et dialogues élégants dans toute l'application
// class DialogService {

//   /// Affiche un toast animé de succès
//   static void showSuccess(
//       BuildContext context,
//       String message, {
//         Duration duration = const Duration(seconds: 3),
//       }) {
//     _showAnimatedToast(
//       context,
//       message: message,
//       icon: Icons.check_circle_rounded,
//       gradient: LinearGradient(
//         colors: [Color(0xFF10b981), Color(0xFF059669)],
//       ),
//       duration: duration,
//     );
//   }

//   /// Affiche un toast animé d'erreur
//   static void showError(
//       BuildContext context,
//       String message, {
//         Duration duration = const Duration(seconds: 4),
//       }) {
//     _showAnimatedToast(
//       context,
//       message: message,
//       icon: Icons.error_rounded,
//       gradient: LinearGradient(
//         colors: [Color(0xFFef4444), Color(0xFFdc2626)],
//       ),
//       duration: duration,
//     );
//   }

//   /// Affiche un toast animé d'information
//   static void showInfo(
//       BuildContext context,
//       String message, {
//         Duration duration = const Duration(seconds: 3),
//       }) {
//     _showAnimatedToast(
//       context,
//       message: message,
//       icon: Icons.info_rounded,
//       gradient: LinearGradient(
//         colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
//       ),
//       duration: duration,
//     );
//   }

//   /// Affiche un toast animé d'avertissement
//   static void showWarning(
//       BuildContext context,
//       String message, {
//         Duration duration = const Duration(seconds: 3),
//       }) {
//     _showAnimatedToast(
//       context,
//       message: message,
//       icon: Icons.warning_rounded,
//       gradient: LinearGradient(
//         colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
//       ),
//       duration: duration,
//     );
//   }

//   /// Méthode privée pour afficher un toast animé personnalisé
//   static void _showAnimatedToast(
//       BuildContext context, {
//         required String message,
//         required IconData icon,
//         required Gradient gradient,
//         required Duration duration,
//       }) {
//     OverlayState? overlayState = Overlay.of(context);
//     late OverlayEntry overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder: (context) => _AnimatedToast(
//         message: message,
//         icon: icon,
//         gradient: gradient,
//         duration: duration,
//         onDismiss: () => overlayEntry.remove(),
//       ),
//     );

//     overlayState.insert(overlayEntry);
//   }

//   /// Affiche une boîte de dialogue de confirmation moderne
//   static Future<bool> showConfirmation(
//       BuildContext context, {
//         required String title,
//         required String message,
//         String confirmText = 'Confirmer',
//         String cancelText = 'Annuler',
//         Color? confirmColor,
//         IconData? icon,
//         bool isDangerous = false,
//       }) async {
//     final result = await showGeneralDialog<bool>(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: Duration(milliseconds: 300),
//       pageBuilder: (context, anim1, anim2) {
//         return Container();
//       },
//       transitionBuilder: (context, anim1, anim2, child) {
//         return ScaleTransition(
//           scale: Tween<double>(begin: 0.8, end: 1.0).animate(
//             CurvedAnimation(
//               parent: anim1,
//               curve: Curves.easeOutBack,
//             ),
//           ),
//           child: FadeTransition(
//             opacity: anim1,
//             child: _ConfirmationDialog(
//               title: title,
//               message: message,
//               confirmText: confirmText,
//               cancelText: cancelText,
//               confirmColor: confirmColor,
//               icon: icon,
//               isDangerous: isDangerous,
//             ),
//           ),
//         );
//       },
//     );

//     return result ?? false;
//   }

//   /// Affiche une boîte de dialogue d'information moderne
//   static Future<void> showInfoDialog(
//       BuildContext context, {
//         required String title,
//         required String message,
//         String buttonText = 'OK',
//         IconData? icon,
//         Color? iconColor,
//       }) async {
//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: Duration(milliseconds: 300),
//       pageBuilder: (context, anim1, anim2) {
//         return Container();
//       },
//       transitionBuilder: (context, anim1, anim2, child) {
//         return ScaleTransition(
//           scale: Tween<double>(begin: 0.8, end: 1.0).animate(
//             CurvedAnimation(
//               parent: anim1,
//               curve: Curves.easeOutBack,
//             ),
//           ),
//           child: FadeTransition(
//             opacity: anim1,
//             child: _InfoDialog(
//               title: title,
//               message: message,
//               buttonText: buttonText,
//               icon: icon,
//               iconColor: iconColor,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Affiche un loading overlay professionnel
//   static OverlayEntry showLoading(
//       BuildContext context,
//       String message,
//       ) {
//     OverlayState overlayState = Overlay.of(context);

//     OverlayEntry overlayEntry = OverlayEntry(
//       builder: (context) => _LoadingOverlay(message: message),
//     );

//     overlayState.insert(overlayEntry);
//     return overlayEntry;
//   }
// }

// // ==================== WIDGETS PRIVÉS ====================

// /// Widget de toast animé
// class _AnimatedToast extends StatefulWidget {
//   final String message;
//   final IconData icon;
//   final Gradient gradient;
//   final Duration duration;
//   final VoidCallback onDismiss;

//   const _AnimatedToast({
//     required this.message,
//     required this.icon,
//     required this.gradient,
//     required this.duration,
//     required this.onDismiss,
//   });

//   @override
//   _AnimatedToastState createState() => _AnimatedToastState();
// }

// class _AnimatedToastState extends State<_AnimatedToast>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 400),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutCubic,
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     ));

//     _controller.forward();

//     Future.delayed(widget.duration, () {
//       if (mounted) {
//         _controller.reverse().then((_) => widget.onDismiss());
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 50,
//       left: 16,
//       right: 16,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: widget.gradient,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       widget.icon,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       widget.message,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, color: Colors.white, size: 20),
//                     onPressed: () {
//                       _controller.reverse().then((_) => widget.onDismiss());
//                     },
//                     padding: EdgeInsets.zero,
//                     constraints: BoxConstraints(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Widget de dialogue de confirmation
// class _ConfirmationDialog extends StatelessWidget {
//   final String title;
//   final String message;
//   final String confirmText;
//   final String cancelText;
//   final Color? confirmColor;
//   final IconData? icon;
//   final bool isDangerous;

//   const _ConfirmationDialog({
//     required this.title,
//     required this.message,
//     required this.confirmText,
//     required this.cancelText,
//     this.confirmColor,
//     this.icon,
//     required this.isDangerous,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final accentColor = confirmColor ?? (isDangerous ? Color(0xFFef4444) : Color(0xFF667eea));

//     return Center(
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 24),
//         padding: EdgeInsets.all(28),
//         decoration: BoxDecoration(
//           color: isDark ? Color(0xFF1e1e2e) : Colors.white,
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 40,
//               offset: Offset(0, 20),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icon avec gradient
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       accentColor.withOpacity(0.2),
//                       accentColor.withOpacity(0.05),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: accentColor.withOpacity(0.3),
//                     width: 2,
//                   ),
//                 ),
//                 child: Icon(
//                   icon ?? (isDangerous ? Icons.warning_rounded : Icons.help_outline_rounded),
//                   size: 40,
//                   color: accentColor,
//                 ),
//               ),
//               SizedBox(height: 24),

//               // Title
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                   letterSpacing: 0.3,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 12),

//               // Message
//               Text(
//                 message,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: isDark ? Colors.white70 : Colors.black54,
//                   height: 1.6,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 32),

//               // Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       height: 52,
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           side: BorderSide(
//                             color: isDark ? Colors.white24 : Colors.grey.shade300,
//                             width: 2,
//                           ),
//                         ),
//                         child: Text(
//                           cancelText,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: isDark ? Colors.white70 : Colors.black54,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       height: 52,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [accentColor, accentColor.withOpacity(0.8)],
//                         ),
//                         borderRadius: BorderRadius.circular(14),
//                         boxShadow: [
//                           BoxShadow(
//                             color: accentColor.withOpacity(0.4),
//                             blurRadius: 12,
//                             offset: Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: ElevatedButton(
//                         onPressed: () => Navigator.of(context).pop(true),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shadowColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         child: Text(
//                           confirmText,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Widget de dialogue d'information
// class _InfoDialog extends StatelessWidget {
//   final String title;
//   final String message;
//   final String buttonText;
//   final IconData? icon;
//   final Color? iconColor;

//   const _InfoDialog({
//     required this.title,
//     required this.message,
//     required this.buttonText,
//     this.icon,
//     this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final accentColor = iconColor ?? Color(0xFF667eea);

//     return Center(
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 24),
//         padding: EdgeInsets.all(28),
//         decoration: BoxDecoration(
//           color: isDark ? Color(0xFF1e1e2e) : Colors.white,
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 40,
//               offset: Offset(0, 20),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       accentColor.withOpacity(0.2),
//                       accentColor.withOpacity(0.05),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: accentColor.withOpacity(0.3),
//                     width: 2,
//                   ),
//                 ),
//                 child: Icon(
//                   icon ?? Icons.info_outline_rounded,
//                   size: 40,
//                   color: accentColor,
//                 ),
//               ),
//               SizedBox(height: 24),

//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                   letterSpacing: 0.3,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 12),

//               Text(
//                 message,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: isDark ? Colors.white70 : Colors.black54,
//                   height: 1.6,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 32),

//               Container(
//                 width: double.infinity,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [accentColor, accentColor.withOpacity(0.8)],
//                   ),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: accentColor.withOpacity(0.4),
//                       blurRadius: 12,
//                       offset: Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     buttonText,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Widget de loading overlay
// class _LoadingOverlay extends StatelessWidget {
//   final String message;

//   const _LoadingOverlay({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black.withOpacity(0.7),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//           decoration: BoxDecoration(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? Color(0xFF1e1e2e)
//                 : Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 30,
//                 offset: Offset(0, 15),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 4,
//                   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 message,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Theme.of(context).brightness == Brightness.dark
//                       ? Colors.white
//                       : Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

/// Service pour afficher des overlays et dialogues élégants dans toute l'application
class DialogService {

  /// Affiche un toast animé de succès
  static void showSuccess(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _showAnimatedToast(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF10b981), Color(0xFF059669)],
      ),
      duration: duration,
    );
  }

  /// Affiche un toast animé d'erreur
  static void showError(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
      }) {
    _showAnimatedToast(
      context,
      message: message,
      icon: Icons.error_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFFef4444), Color(0xFFdc2626)],
      ),
      duration: duration,
    );
  }

  /// Affiche un toast animé d'information
  static void showInfo(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _showAnimatedToast(
      context,
      message: message,
      icon: Icons.info_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
      ),
      duration: duration,
    );
  }

  /// Affiche un toast animé d'avertissement
  static void showWarning(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _showAnimatedToast(
      context,
      message: message,
      icon: Icons.warning_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
      ),
      duration: duration,
    );
  }

  /// Méthode privée pour afficher un toast animé personnalisé
  static void _showAnimatedToast(
      BuildContext context, {
        required String message,
        required IconData icon,
        required Gradient gradient,
        required Duration duration,
      }) {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedToast(
        message: message,
        icon: icon,
        gradient: gradient,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);
  }

  /// Affiche une boîte de dialogue de confirmation moderne
  static Future<bool> showConfirmation(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirmer',
        String cancelText = 'Annuler',
        Color? confirmColor,
        IconData? icon,
        bool isDangerous = false,
      }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: anim1,
            child: _ConfirmationDialog(
              title: title,
              message: message,
              confirmText: confirmText,
              cancelText: cancelText,
              confirmColor: confirmColor,
              icon: icon,
              isDangerous: isDangerous,
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  /// Affiche une boîte de dialogue d'information moderne
  static Future<void> showInfoDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
        IconData? icon,
        Color? iconColor,
      }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: anim1,
            child: _InfoDialog(
              title: title,
              message: message,
              buttonText: buttonText,
              icon: icon,
              iconColor: iconColor,
            ),
          ),
        );
      },
    );
  }

  /// Affiche un loading overlay professionnel avec animation
  static OverlayEntry showLoading(
      BuildContext context,
      String message,
      ) {
    OverlayState overlayState = Overlay.of(context);

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlay(message: message),
    );

    overlayState.insert(overlayEntry);
    return overlayEntry;
  }
}

// ==================== WIDGETS PRIVÉS ====================

/// Widget de toast animé
class _AnimatedToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Gradient gradient;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.message,
    required this.icon,
    required this.gradient,
    required this.duration,
    required this.onDismiss,
  });

  @override
  _AnimatedToastState createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de dialogue de confirmation
class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final bool isDangerous;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor,
    this.icon,
    required this.isDangerous,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = confirmColor ?? (isDangerous ? Color(0xFFef4444) : Color(0xFF667eea));

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1e1e2e) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon avec gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.2),
                      accentColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon ?? (isDangerous ? Icons.warning_rounded : Icons.help_outline_rounded),
                  size: 40,
                  color: accentColor,
                ),
              ),
              SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}

/// Widget de dialogue d'information
class _InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData? icon;
  final Color? iconColor;

  const _InfoDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = iconColor ?? Color(0xFF667eea);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1e1e2e) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.2),
                      accentColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon ?? Icons.info_outline_rounded,
                  size: 40,
                  color: accentColor,
                ),
              ),
              SizedBox(height: 24),

              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

/// Widget de loading overlay avec animation améliorée
class _LoadingOverlay extends StatefulWidget {
  final String message;

  const _LoadingOverlay({required this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1e1e2e) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated loading spinner with gradient effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF667eea).withOpacity(0.1),
                              Color(0xFF764ba2).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      // Rotating progress indicator
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF667eea),
                          ),
                        ),
                      ),
                      // Center icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.hourglass_empty_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Loading message
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  // Subtitle with animation
                  _PulsingDots(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dots pulsants pour effet de chargement
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final opacity = ((_animation.value + delay) % 1.0) > 0.5 ? 1.0 : 0.3;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? Colors.white70 : Colors.black54)
                      .withOpacity(opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}