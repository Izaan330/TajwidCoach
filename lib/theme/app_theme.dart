import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFFA5D6A7);
  static const Color accentAmber = Color(0xFFFF9800);
  static const Color accentAmberDark = Color(0xFFF57C00);
  static const Color backgroundCream = Color(0xFFFAFAFA); // Clean off-white like Quran.com
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFEEEEEE);

  // Tajwid Rule Colors
  static const Color idghamBlue = Color(0xFF1565C0);
  static const Color idghamBlueBg = Color(0xFFE3F2FD);
  static const Color ikhfaGreen = Color(0xFF2E7D32);
  static const Color ikhfaGreenBg = Color(0xFFE8F5E8);
  static const Color qalqalahRed = Color(0xFFC62828);
  static const Color qalqalahRedBg = Color(0xFFFFEBEE);
  static const Color maddAmber = Color(0xFFF57F17);
  static const Color maddAmberBg = Color(0xFFFFFDE7);
  static const Color ghunnahTeal = Color(0xFF1B5E20);
  static const Color ghunnahTealBg = Color(0xFFE8F5E9);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Premium Gold
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGoldLight = Color(0xFFFFF9C4);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentAmber,
        surface: cardWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundCream,
      appBarTheme: AppBarTheme(
        backgroundColor: cardWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      cardTheme: const CardThemeData(
        color: cardWhite,
        elevation: 2,
        shadowColor: Colors.black12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundCream,
        selectedColor: primaryGreenLight,
        labelStyle: GoogleFonts.roboto(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: textSecondary),
        hintStyle: GoogleFonts.roboto(color: textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.roboto(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.roboto(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.roboto(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.roboto(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textHint,
        ),
      ),
    );
  }

  // Helper: score to color
  static Color scoreColor(int score) {
    if (score >= 90) return success;
    if (score >= 75) return primaryGreen;
    if (score >= 60) return warning;
    return error;
  }

  // Gradient for premium sections
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

