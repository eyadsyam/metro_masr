import 'package:flutter/material.dart';

// import 'package:arabic_font/arabic_font.dart';

class MetroTheme {
  // ========== LIGHT MODE ==========
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightPrimary = Color(0xFF1976D2); // Material Blue
  static const Color lightSecondary = Color(0xFF00ACC1); // Cyan
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF212121);

  // ========== DARK MODE - Midnight & Neon Theme ==========
  static const Color darkBackground = Color(0xFF0B101B); // Deepest Midnight
  static const Color darkPrimary = Color(0xFF3B82F6); // Electric Blue
  static const Color darkSecondary = Color(0xFF8B5CF6); // Neon Violet
  static const Color darkSurface = Color(0xFF151B2B); // Rich Navy Surface
  static const Color darkCard = Color(
    0xFF212A3D,
  ); // Slightly lighter for better contrast
  static const Color darkOnSurface = Color(0xFFF1F5F9); // Crisp White/Slate
  static const Color darkAccent = Color(0xFFF472B6); // Hot Pink Accent

  static ThemeData getLightTheme(Locale? locale) {
    // English (default) uses Poppins
    // Arabic uses Tajawal
    final isArabic = locale?.languageCode == 'ar';

    // Fallback ID to prevent offline crash
    final fontFamily = isArabic ? 'Tajawal' : 'Poppins';

    // Apply font family to theme
    ThemeData theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: fontFamily,

      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        background: lightBackground,
        error: const Color(0xFFF44336),
        onPrimary: Colors.white,
        onSurface: lightOnSurface,
        onBackground: lightOnSurface,
      ),

      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dividerColor: const Color(0xFFE0E0E0),
    );

    // Explicitly set text theme if needed, but fontFamily often covers it.
    // ArabicFont package returns a String fontFamily.
    // However, GoogleFonts usually returns a TextTheme or TextStyle.
    // If we rely on fontFamily string, we should ensure the font is loaded.
    // For GoogleFonts, we might need to apply it.

    if (!isArabic) {
      // theme = theme.copyWith(
      //   textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme),
      // );
    } else {
      // ArabicFont package usage:
      // fontFamily: ArabicThemeData.font(ArabicFont.tajawal)
      // This returns the font family string, assuming package handles loading.
    }

    return theme;
  }

  static ThemeData getDarkTheme(Locale? locale) {
    final isArabic = locale?.languageCode == 'ar';

    // Fallback ID to prevent offline crash
    final fontFamily = isArabic ? 'Tajawal' : 'Poppins';

    ThemeData theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: fontFamily,

      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        background: darkBackground,
        error: const Color(0xFFEF5350),
        onPrimary: Colors.white,
        onSurface: darkOnSurface,
        onBackground: darkOnSurface,
        tertiary: darkAccent,
        outline: darkOnSurface.withOpacity(0.5),
        outlineVariant: darkOnSurface.withOpacity(0.2),
        surfaceVariant: darkCard,
        onSurfaceVariant: darkOnSurface.withOpacity(0.6),
      ),

      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // More premium
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: darkPrimary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),

      dividerColor: darkOnSurface.withOpacity(0.1),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ), // Default to white for visibility

      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: darkOnSurface,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: darkOnSurface),
        bodyMedium: TextStyle(color: darkOnSurface.withOpacity(0.8)),
      ),
      splashColor: darkPrimary.withOpacity(0.1),
      highlightColor: Colors.transparent,
    );

    if (!isArabic) {
      // Potentially use GoogleFonts if available, otherwise Poppins via fontFamily is fine.
    }

    return theme;
  }
}
