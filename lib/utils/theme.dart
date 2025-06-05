import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF3366FF);
  static const Color secondaryColor = Color(0xFF2EC4B6);
  static const Color accentColor = Color(0xFFFF9F1C);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color warningColor = Color(0xFFFFD166);
  static const Color successColor = Color(0xFF06D6A0);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Color(0xFF1E2022);
  static const Color lightOnBackground = Color(0xFF1E2022);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFF8F9FA);
  static const Color darkOnBackground = Color(0xFFF8F9FA);
  
  // Text styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.normal,
    fontSize: 12,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 1.25,
  );
  
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightOnSurface,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: lightOnSurface),
      titleTextStyle: TextStyle(
        color: lightOnSurface,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: lightSurface,
      ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF666666),
        fontFamily: 'Poppins',
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF999999),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: headline1,
      displayMedium: headline2,
      displaySmall: headline3,
      titleMedium: subtitle1,
      bodyLarge: bodyText1,
      bodyMedium: bodyText2,
      labelLarge: button,
    ),
  );
  
  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkOnSurface,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: darkOnSurface),
      titleTextStyle: TextStyle(
        color: darkOnSurface,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
      cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: darkSurface,
  ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFFAAAAAA),
        fontFamily: 'Poppins',
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF999999),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF333333),
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: headline1,
      displayMedium: headline2,
      displaySmall: headline3,
      titleMedium: subtitle1,
      bodyLarge: bodyText1,
      bodyMedium: bodyText2,
      labelLarge: button,
    ),
  );
}