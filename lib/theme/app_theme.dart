import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand / Core Colors ───────────────────────────────────────────────────
  static const Color primaryGreen      = Color(0xFF00C853); // vivid emerald
  static const Color primaryGreenDark  = Color(0xFF00963E);
  static const Color primaryGreenLight = Color(0xFF69F0AE);

  static const Color accentAmber     = Color(0xFFFFB300);
  static const Color accentAmberDark = Color(0xFFFF8F00);

  // ─── Dark Background System ────────────────────────────────────────────────
  static const Color backgroundDark     = Color(0xFF080E1A); // deepest navy
  static const Color backgroundMid      = Color(0xFF0D1628); // main scaffold
  static const Color backgroundSurface  = Color(0xFF141F35); // card/sheet bg
  static const Color backgroundElevated = Color(0xFF1A2744); // elevated cards

  // Legacy aliases (screens not yet refactored)
  static const Color backgroundCream = backgroundMid;
  static const Color cardWhite       = backgroundSurface;

  // ─── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8FA3C8);
  static const Color textHint      = Color(0xFF4A5A7A);
  static const Color divider       = Color(0xFF1E2D4A);

  // ─── Gold / Premium ────────────────────────────────────────────────────────
  static const Color premiumGold      = Color(0xFFFFD54F);
  static const Color premiumGoldLight = Color(0xFFFFF8E1);
  static const Color premiumGoldDark  = Color(0xFFF9A825);

  // ─── Tajwid Rule Colors ────────────────────────────────────────────────────
  static const Color idghamBlue    = Color(0xFF82B1FF);
  static const Color idghamBlueBg  = Color(0xFF0D1F3C);
  static const Color ikhfaGreen    = Color(0xFF69F0AE);
  static const Color ikhfaGreenBg  = Color(0xFF0A2318);
  static const Color qalqalahRed   = Color(0xFFFF5252);
  static const Color qalqalahRedBg = Color(0xFF2A0A0A);
  static const Color maddAmber     = Color(0xFFFFD740);
  static const Color maddAmberBg   = Color(0xFF2A1E00);
  static const Color ghunnahTeal   = Color(0xFF40C4FF);
  static const Color ghunnahTealBg = Color(0xFF001F2E);

  // ─── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error   = Color(0xFFFF5252);
  static const Color info    = Color(0xFF40C4FF);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient islamicGradient = LinearGradient(
    colors: [Color(0xFF004D40), Color(0xFF080E1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFA726)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [backgroundMid, backgroundDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Glassmorphism Helper ──────────────────────────────────────────────────
  static BoxDecoration glassmorphicDecoration({
    double opacity = 0.08,
    double borderOpacity = 0.18,
    double borderRadius = 20,
    Color baseColor = const Color(0xFF82B1FF),
  }) {
    return BoxDecoration(
      color: baseColor.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: baseColor.withValues(alpha: borderOpacity),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ─── Score Color ───────────────────────────────────────────────────────────
  static Color scoreColor(int score) {
    if (score >= 90) return success;
    if (score >= 75) return primaryGreen;
    if (score >= 60) return warning;
    return error;
  }

  // ─── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme();

  static ThemeData _buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentAmber,
        surface: backgroundSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundMid,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundMid,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: backgroundSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundElevated,
        selectedColor: primaryGreen.withValues(alpha: 0.25),
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: divider, width: 1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.outfit(color: textSecondary),
        hintStyle: GoogleFonts.outfit(color: textHint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      dividerColor: divider,
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primaryGreen : textHint),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primaryGreen.withValues(alpha: 0.3)
                : backgroundElevated),
      ),
      textTheme: _buildTextTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge:
          GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.w300, color: textPrimary),
      displayMedium:
          GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.w300, color: textPrimary),
      displaySmall:
          GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w400, color: textPrimary),
      headlineLarge:
          GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium:
          GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
      headlineSmall:
          GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge:
          GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium:
          GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall:
          GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge:
          GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium:
          GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      bodySmall:
          GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
      labelLarge:
          GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      labelMedium:
          GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      labelSmall:
          GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: textHint),
    );
  }
}
