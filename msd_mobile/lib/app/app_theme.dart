import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary       = Color(0xFF3EC6B8);
  static const Color primaryLight  = Color(0xFFE8F8F6);
  static const Color primaryDark   = Color(0xFF2FAF9F);
  static const Color textDark      = Color(0xFF1A1A2E);
  static const Color textGrey      = Color(0xFF9E9E9E);
  static const Color background    = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark      = Color(0xFF1E1E1E);
  static const Color fieldBg       = Color(0xFFF5F5F5);
  static const Color fieldBgDark   = Color(0xFF1E1E1E);
  static const Color redAccent     = Color(0xFFFF5252);
  static const Color orangeAccent  = Color(0xFFE8A048);
  static const Color blueAccent    = Color(0xFF4A90D9);

  static InputDecoration textFieldDecoration({required String hint, required bool isDark}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: isDark ? fieldBgDark : fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  static const String googleMapDarkStyle = '''
[
  { "elementType": "geometry", "stylers": [ { "color": "#242f3e" } ] },
  { "elementType": "labels.text.stroke", "stylers": [ { "color": "#242f3e" } ] },
  { "elementType": "labels.text.fill", "stylers": [ { "color": "#746855" } ] },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#d59563" } ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#d59563" } ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [ { "color": "#263c3f" } ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#6b9a76" } ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [ { "color": "#38414e" } ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [ { "color": "#212a37" } ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#9ca5b3" } ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [ { "color": "#746855" } ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [ { "color": "#1f2835" } ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#f3d19c" } ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [ { "color": "#2f3948" } ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#d59563" } ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [ { "color": "#17263c" } ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#515c6d" } ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [ { "color": "#17263c" } ]
  }
]
''';

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: background,
      onSurface: textDark,
      background: background,
      onBackground: textDark,
      outline: Colors.grey.shade200,
      primaryContainer: primaryLight,
      onPrimaryContainer: primary,
    ),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textDark,
      displayColor: textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: textDark),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF888780),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      background: backgroundDark,
      onBackground: Colors.white,
      outline: Colors.white10,
      primaryContainer: primary.withOpacity(0.15),
      onPrimaryContainer: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primary,
      unselectedItemColor: Colors.white60,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white10,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldBgDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}
