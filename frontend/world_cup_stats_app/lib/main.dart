import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'router.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const WorldCupApp());
}

class WorldCupApp extends StatelessWidget {
  const WorldCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'World Cup 2026',
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004B87)),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF004B87), brightness: Brightness.dark),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
