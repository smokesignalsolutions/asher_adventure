import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF6B4226); // warm brown fantasy color

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.all(8),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.all(8),
    ),
  );
}
