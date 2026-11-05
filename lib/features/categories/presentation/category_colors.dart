import 'package:flutter/material.dart';

/// Colors a category can be tagged with.
abstract final class CategoryColors {
  static const defaultColorValue = 0xFF6A1B9A;

  static const palette = <Color>[
    Color(defaultColorValue),
    Color(0xFF1565C0),
    Color(0xFF00838F),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFFC62828),
    Color(0xFF546E7A),
  ];

  static Color of(int colorValue) => Color(colorValue);
}
