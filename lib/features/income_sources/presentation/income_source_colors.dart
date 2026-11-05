import 'package:flutter/material.dart';

/// Colors an income source can be tagged with.
abstract final class IncomeSourceColors {
  static const defaultColorValue = 0xFF2E7D32;

  static const palette = <Color>[
    Color(defaultColorValue),
    Color(0xFF00695C),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFFC62828),
  ];

  static Color of(int colorValue) => Color(colorValue);
}
