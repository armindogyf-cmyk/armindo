import 'package:flutter/material.dart';

class AppTheme {
  static const Color grafiteProfundo = Color(0xFF111418);
  static const Color cinzaArdosia = Color(0xFF222831);
  static const Color turquesaTecnico = Color(0xFF00B4B8);
  static const Color brancoNeutro = Color(0xFFF4F6F8);
  static const Color douradoDiscreto = Color(0xFFC4A962);
  static const Color vermelhoCritico = Color(0xFFD7263D);

  static ThemeData darkInstitutional() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: grafiteProfundo,
      colorScheme: const ColorScheme.dark(
        primary: turquesaTecnico,
        secondary: douradoDiscreto,
        surface: cinzaArdosia,
        error: vermelhoCritico,
        onPrimary: grafiteProfundo,
        onSurface: brancoNeutro,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cinzaArdosia,
        foregroundColor: brancoNeutro,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: cinzaArdosia.withOpacity(0.72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: brancoNeutro,
        displayColor: brancoNeutro,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: cinzaArdosia,
        selectedIconTheme: IconThemeData(color: turquesaTecnico),
        selectedLabelTextStyle: TextStyle(color: turquesaTecnico),
      ),
    );
  }
}
