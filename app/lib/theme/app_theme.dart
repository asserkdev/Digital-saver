import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFEC4899);
  
  // Health Status Colors
  static const Color healthyGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  // Background Colors - Dark
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);
  
  // Background Colors - Light
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFE2E8F0);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient healthGradient = LinearGradient(
    colors: [healthyGreen, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [dangerRed, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heartGradient = LinearGradient(
    colors: [dangerRed, accentColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
  ];
  
  static List<BoxShadow> get hardShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
  ];
  
  // Text Styles
  static TextStyle get headlineLarge => GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static TextStyle get headlineMedium => GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3);
  static TextStyle get headlineSmall => GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get titleLarge => GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get titleMedium => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get bodyLarge => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle get bodyMedium => GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get bodySmall => GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle get labelLarge => GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get labelSmall => GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  
  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(primary: primaryColor, secondary: secondaryColor, surface: lightSurface, error: dangerRed),
    scaffoldBackgroundColor: lightBg,
    cardColor: lightCard,
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: const Color(0xFF1E293B), displayColor: const Color(0xFF1E293B)),
    appBarTheme: AppBarTheme(backgroundColor: lightBg, elevation: 0, centerTitle: true, titleTextStyle: headlineSmall.copyWith(color: const Color(0xFF1E293B))),
    cardTheme: CardTheme(color: lightCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: lightSurface.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: lightCard, selectedItemColor: primaryColor, unselectedItemColor: Colors.grey[400], type: BottomNavigationBarType.fixed, elevation: 0),
  );
  
  // Dark Theme  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(primary: primaryColor, secondary: secondaryColor, surface: darkSurface, error: dangerRed),
    scaffoldBackgroundColor: darkBg,
    cardColor: darkCard,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white),
    appBarTheme: AppBarTheme(backgroundColor: darkBg, elevation: 0, centerTitle: true, titleTextStyle: headlineSmall.copyWith(color: Colors.white)),
    cardTheme: CardTheme(color: darkCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: darkSurface.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: darkCard, selectedItemColor: primaryColor, unselectedItemColor: Colors.grey[500], type: BottomNavigationBarType.fixed, elevation: 0),
  );
}
