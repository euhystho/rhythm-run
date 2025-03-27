import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

// RhythmRun Custom Theme
class RhythmRunTheme {
  // Colors
  static const Color primaryText = Colors.black;
  static const Color primaryDarkModeText = Colors.white;
  static const Color headerText = Colors.transparent;
  static const Color secondaryText = Color(0xFF666666);
  static const Color secondaryDarkModeText = Color(0xFFB3B3B3);

  static const ColorScheme lightScheme = ColorScheme.light(
    primary: Color(0xFFFF6F61),
    secondary: Color(0xFF4A90E2),
    tertiary: Color(0xFF8e44ad),
    surface: Color(0xFFF9F9F9),
    onSurface: Colors.black
  );

  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: Color(0xFFD85D4E),
    secondary: Color(0xFF3B78D2),
    tertiary: Color(0xFF732D91),
    surface: Color(0xFF1C1C1C),
    onSurface: Colors.white
  );

  static Color scaffoldBackgroundColor = Color(0xFF333333);
  static const Color borderColor = Colors.transparent;

  // Spotify Colors
  static const Color spotifyGreen = Color(0xFF1DB954);

  //Apple Music Colors
  static const Color appleMusicRed = Color(0xFFFC3C44);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: lightScheme,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.contrailOne(
          fontSize: 64,
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.contrailOne(
          fontSize: 40,
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: GoogleFonts.comfortaa(fontSize: 14, color: primaryText),
        bodyLarge: GoogleFonts.comfortaa(fontSize: 16, color: primaryText),
        titleSmall: GoogleFonts.contrailOne(fontSize: 16, color: primaryText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightScheme.surface,
          foregroundColor: primaryText,
          textStyle: GoogleFonts.contrailOne(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: darkScheme,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.contrailOne(
          fontSize: 64,
          color: primaryDarkModeText,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.contrailOne(
          fontSize: 40,
          color: primaryDarkModeText,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: GoogleFonts.comfortaa(fontSize: 14, color: primaryDarkModeText),
        bodyLarge: GoogleFonts.comfortaa(fontSize: 16, color: primaryDarkModeText),
        titleSmall: GoogleFonts.contrailOne(fontSize: 16, color: primaryDarkModeText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkScheme.surface,
          foregroundColor: darkScheme.onSurface,
          textStyle: GoogleFonts.contrailOne(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
    );
  }
}

// Helper Widgets
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ResponsiveText({
    required this.text,
    this.style,
    this.textAlign,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: textAlign);
  }
}

// Loading Indicator
Widget loadingIndicator(context) {
  return SpinKitPumpingHeart(color: Theme.of(context).colorScheme.primary, size: 50);
}
