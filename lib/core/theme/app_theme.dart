import 'package:flutter/material.dart';

/// AppTheme: centralized, modern Material 3 theme used across the app.
class AppTheme {
  /// Returns a light theme using [seedColor] as a ColorScheme seed.
  static ThemeData lightTheme({Color? seedColor}) {
    final seed = seedColor ?? const Color(0xFF6750A4);
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

    return base.copyWith(
      colorScheme: scheme,
  scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 1,
        centerTitle: true,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: scheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    );
  }
}
