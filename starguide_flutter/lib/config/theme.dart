import 'package:flutter/material.dart';

ThemeData createTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
    surface: Colors.white,
    primary: Colors.blueAccent,
    surfaceContainerLow: Colors.blueGrey.shade50,
  );

  return ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    dividerColor: Colors.grey.shade400,
  ).copyWith(
    colorScheme: colorScheme,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        foregroundColor: Colors.grey.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
}
