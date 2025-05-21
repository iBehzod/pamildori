import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary colors
  static const Color primaryRed = Color(0xFFE57373);
  static const Color primaryBlue = Color(0xFF64B5F6);
  static const Color primaryGreen = Color(0xFF81C784);
  static const Color primaryPurple = Color(0xFFBA68C8);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnBackground = Color(0xFF121212);
  static const Color lightOnSurface = Color(0xFF121212);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnBackground = Color(0xFFFAFAFA);
  static const Color darkOnSurface = Color(0xFFFAFAFA);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return _buildTheme(
      baseTheme,
      AppColors.primaryRed,
      AppColors.lightBackground,
      AppColors.lightSurface,
      AppColors.lightOnBackground,
      AppColors.lightOnSurface,
      AppColors.lightError,
    );
  }
  
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return _buildTheme(
      baseTheme,
      AppColors.primaryRed,
      AppColors.darkBackground,
      AppColors.darkSurface,
      AppColors.darkOnBackground,
      AppColors.darkOnSurface,
      AppColors.darkError,
    );
  }
  
  static ThemeData getThemeWithAccentColor(ThemeData base, String colorName) {
    Color primaryColor;
    
    switch (colorName.toLowerCase()) {
      case 'blue':
        primaryColor = AppColors.primaryBlue;
        break;
      case 'green':
        primaryColor = AppColors.primaryGreen;
        break;
      case 'purple':
        primaryColor = AppColors.primaryPurple;
        break;
      case 'tomato':
      default:
        primaryColor = AppColors.primaryRed;
    }
    
    return base.copyWith(
      primaryColor: primaryColor,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: primaryColor,
      ),
    );
  }
  
  static ThemeData _buildTheme(
    ThemeData base,
    Color primaryColor,
    Color backgroundColor,
    Color surfaceColor,
    Color onBackgroundColor,
    Color onSurfaceColor,
    Color errorColor,
  ) {
    final textTheme = _buildTextTheme(base.textTheme);
    
    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        onBackground: onBackgroundColor,
        onSurface: onSurfaceColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: onBackgroundColor,
        ),
        iconTheme: IconThemeData(
          color: onBackgroundColor,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: onBackgroundColor.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: onBackgroundColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorColor,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorColor,
            width: 1.5,
          ),
        ),
      ),
      textTheme: textTheme,
    );
  }
  
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}