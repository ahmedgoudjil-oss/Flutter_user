import 'package:flutter/material.dart';

class AppColors {
  // Blue and White Color Scheme
  static const Color primary = Color(0xFF1E40AF); // Blue 700
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1E3A8A); // Blue 800

  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color secondaryLight = Color(0xFF94A3B8); // Slate 400
  static const Color secondaryDark = Color(0xFF475569); // Slate 600

  static const Color accent = Color(0xFF1E40AF); // Blue 700
  static const Color accentLight = Color(0xFF3B82F6); // Blue 500
  static const Color accentDark = Color(0xFF1E3A8A); // Blue 800

  // Neutral Colors
  static const Color background = Color(0xFF1E40AF); // Blue background
  static const Color backgroundSecondary = Color(0xFF3B82F6); // Light blue
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceSecondary = Color(0xFFF8FAFC); // Very light gray

  static const Color textPrimary = Color(0xFF1E293B); // Dark gray
  static const Color textSecondary = Color(0xFF64748B); // Medium gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light gray

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red

  // Glassmorphism Colors
  static const Color glassBg = Color(0x80FFFFFF); // Semi-transparent white
  static const Color glassBorder = Color(0x40FFFFFF); // Light white border

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1E40AF), // Blue 700
    Color(0xFF3B82F6), // Blue 500
    Color(0xFF60A5FA), // Blue 400
  ];

  static const List<Color> heroGradient = [
    Color(0xFF1E40AF), // Blue 700
    Color(0xFF3B82F6), // Blue 500
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981), // Green
    Color(0xFF059669), // Dark green
  ];

  // Border and Outline Colors
  static const Color outline = Color(0xFFE2E8F0); // Light gray border
  static const Color outlineSecondary = Color(0xFFCBD5E1); // Medium gray border

  // Header Gradient (keeping for backward compatibility)
  static const List<Color> headerGradient = [
    Color(0xFF1E40AF), // Blue 700
    Color(0xFF3B82F6), // Blue 500
    Color(0xFF60A5FA), // Blue 400
  ];

  // Flash Sale Colors (keeping for backward compatibility)
  static const Color flashBg = Color(0xFFFFFBEB); // Light amber background
  static const Color flashBorder = Color(0xFFF59E0B); // Amber border
  static const Color countdownBg = Color(0xFFEF4444); // Red background

  static const List<Color> saleGradient = [
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
  ];
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.transparent,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceSecondary,
        side: const BorderSide(color: AppColors.outline),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: StadiumBorder(side: const BorderSide(color: AppColors.outline)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        selectedColor: AppColors.primary.withOpacity(0.12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: const Color(0xFF1E293B),
        background: const Color(0xFF0F172A),
        error: const Color(0xFFEF4444),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF6366F1),
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
