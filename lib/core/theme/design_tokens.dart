import 'package:flutter/material.dart';

/// Design Tokens: ألوان، أحجام، مسافات موحدة للتصميم الاحترافي.

class DesignTokens {
  // Spacing (8px grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Shadows for cards/elevations
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: const Color(0x0F000000), blurRadius: 10, offset: const Offset(0, 4)),
    BoxShadow(color: const Color(0x14000000), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  // Radii
  static BorderRadius get cardRadius => const BorderRadius.all(Radius.circular(20));

  // Professional e-commerce colors
  static const Color primary = Color(0xFF6750A4);
  static const Color gold = Color(0xFFFFD700);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE53935);
  static const Color shadowColor = Color(0x1A000000);
}
