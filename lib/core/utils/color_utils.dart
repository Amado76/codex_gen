import 'package:flutter/material.dart';

Color darkenColor(Color c, double amount) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Color lightenColor(Color c, double amount) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color contrastTextColor(Color bg) =>
    bg.computeLuminance() > 0.35 ? const Color(0xFF1A1A1A) : Colors.white;

Color? parseHex(String raw) {
  final hex = raw.replaceAll('#', '').trim();
  if (hex.length != 6) return null;
  final v = int.tryParse('FF$hex', radix: 16);
  return v != null ? Color(v) : null;
}

String colorToHex(Color c) =>
    c.toARGB32().toRadixString(16).substring(2).toUpperCase();
