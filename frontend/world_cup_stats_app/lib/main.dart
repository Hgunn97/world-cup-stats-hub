import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'router.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const WorldCupApp());
}

class WorldCupApp extends StatelessWidget {
  const WorldCupApp({super.key});

  // Primary: deep FIFA blue
  // Secondary: gold/amber — trophies, highlights, top rank
  // Tertiary: crimson red — goals, danger, energy
  static const _seed = Color(0xFF1565C0);
  static const _gold = Color(0xFFD97706);
  static const _red = Color(0xFFDC2626);

  static ColorScheme _lightScheme() => ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.light,
      ).copyWith(
        secondary: _gold,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFFEF3C7),
        onSecondaryContainer: const Color(0xFF78350F),
        tertiary: _red,
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFFEE2E2),
        onTertiaryContainer: const Color(0xFF7F1D1D),
      );

  static ColorScheme _darkScheme() => ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: const Color(0xFFF59E0B),
        onSecondary: Colors.black,
        secondaryContainer: const Color(0xFF451A03),
        onSecondaryContainer: const Color(0xFFFEF3C7),
        tertiary: const Color(0xFFF87171),
        onTertiary: Colors.black,
        tertiaryContainer: const Color(0xFF7F1D1D),
        onTertiaryContainer: const Color(0xFFFEE2E2),
      );

  static CardThemeData _cardTheme() => CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: Color(0xFF1565C0),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 2,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'World Cup 2026',
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: _lightScheme(),
        useMaterial3: true,
        cardTheme: _cardTheme(),
        appBarTheme: _lightAppBarTheme,
        chipTheme: ChipThemeData(
          selectedColor: const Color(0xFF1565C0).withAlpha(30),
          labelStyle: const TextStyle(fontSize: 12),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: _darkScheme(),
        useMaterial3: true,
        cardTheme: _cardTheme(),
        appBarTheme: _darkAppBarTheme,
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(fontSize: 12),
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
