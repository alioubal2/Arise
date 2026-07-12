import 'package:flutter/material.dart';

/// Palette de couleurs d'Arise.
///
/// Identité : accent turquoise sur fonds sombres, pensée pour une utilisation
/// nocturne (réveil) et un fort contraste. Le cahier des charges prévoit un
/// logo fonctionnant en noir et blanc pur ; la couleur reste un renfort, jamais
/// le seul porteur d'information.
class AppColors {
  AppColors._();

  // --- Couleurs de marque (fournies) ---------------------------------------
  /// Accent principal — turquoise clair.
  static const Color primary = Color(0xFF53BFD1);

  /// Accent secondaire — teal foncé (états pressés, éléments atténués).
  static const Color secondary = Color(0xFF377F8B);

  /// Fond / surface sombre — bleu nuit.
  static const Color backgroundDark = Color(0xFF0B2024);

  /// Noir pur — fond profond, écran d'alarme.
  static const Color black = Color(0xFF000000);

  // --- Dérivées utilitaires -------------------------------------------------
  /// Surface légèrement surélevée au-dessus du fond sombre (cartes, feuilles).
  static const Color surfaceDark = Color(0xFF102A30);

  /// Texte principal sur fond sombre.
  static const Color onDark = Color(0xFFF2F6F7);

  /// Texte secondaire / atténué sur fond sombre.
  static const Color onDarkMuted = Color(0xFF9BB0B5);

  /// Blanc pur.
  static const Color white = Color(0xFFFFFFFF);

  // --- États sémantiques ----------------------------------------------------
  static const Color success = Color(0xFF3FBF8F);
  static const Color error = Color(0xFFE5534B);
  static const Color warning = Color(0xFFE0A64B);
}
