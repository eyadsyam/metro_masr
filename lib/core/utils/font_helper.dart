import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:arabic_font/arabic_font.dart';

/// Font Helper
/// Provides appropriate fonts based on locale
class FontHelper {
  /// Get text style with appropriate font for locale
  static TextStyle getTextStyle({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    if (isArabic) {
      return TextStyle(
        fontFamily: 'Tajawal',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    } else {
      return TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
  }

  /// Get display large style
  static TextStyle displayLarge(BuildContext context, {Color? color}) {
    return getTextStyle(
      context: context,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Get title large style
  static TextStyle titleLarge(BuildContext context, {Color? color}) {
    return getTextStyle(
      context: context,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Get title medium style
  static TextStyle titleMedium(BuildContext context, {Color? color}) {
    return getTextStyle(
      context: context,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Get body large style
  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    return getTextStyle(context: context, fontSize: 16, color: color);
  }

  /// Get body medium style
  static TextStyle bodyMedium(BuildContext context, {Color? color}) {
    return getTextStyle(context: context, fontSize: 14, color: color);
  }
}
