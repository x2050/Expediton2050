import 'package:flutter/material.dart';

class ExpeditionTheme {
  static const parchment = Color(0xFFF1E8D6);
  static const paper = Color(0xFFFFFBF2);
  static const ink = Color(0xFF292820);
  static const mutedInk = Color(0xFF746D60);
  static const vermilion = Color(0xFFB94735);
  static const olive = Color(0xFF77764E);
  static const line = Color(0xFFD8CDBA);
  static const charcoal = Color(0xFF25231F);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: vermilion,
      brightness: Brightness.light,
      surface: paper,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: parchment,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: parchment,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: Color(0xFFEBD8CC),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
