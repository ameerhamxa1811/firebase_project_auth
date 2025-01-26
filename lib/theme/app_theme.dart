import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xFF8E2DE2),
      scaffoldBackgroundColor: Color(0xFF140121),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.purpleAccent),
      ),
    );
  }

  static const Color gradientStart = Color(0xFF8E2DE2);
  static const Color gradientEnd = Color(0xFF4A00E0);
  static const Color textColor = Colors.white;
  static const Color hintColor = Colors.grey;
}
