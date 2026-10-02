import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'featurama_theme.dart';

List<double> _colorToHsl(Color color) {
  final hsl = HSLColor.fromColor(color);
  return [
    hsl.hue.roundToDouble(),
    (hsl.saturation * 100).roundToDouble(),
    (hsl.lightness * 100).roundToDouble(),
  ];
}

Color _hslToColor(double h, double s, double l) {
  s /= 100;
  l /= 100;
  final a = s * min(l, 1 - l);
  double f(double n) {
    final k = (n + h / 30) % 12;
    return l - a * max(min(k - 3, min(9 - k, 1.0)), -1.0);
  }

  return Color.fromARGB(
      255, (f(0) * 255).round(), (f(8) * 255).round(), (f(4) * 255).round());
}

double _relativeLuminance(Color c) => c.computeLuminance();

FeaturamaTheme createTheme(Color accentColor, Brightness brightness) {
  final hsl = _colorToHsl(accentColor);
  final h = hsl[0];
  final s = hsl[1];
  final isDark = brightness == Brightness.dark;

  final accentLight =
      isDark ? _hslToColor(h, min(s, 30), 20) : _hslToColor(h, min(s, 40), 92);

  final accentForeground = _relativeLuminance(accentColor) > 0.4
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);

  if (isDark) {
    return FeaturamaTheme(
      background: const Color(0xFF000000),
      card: const Color(0xFF1C1C1E),
      secondary: const Color(0xFF2C2C2E),
      text: const Color(0xFFFFFFFF),
      textSecondary: const Color(0xFF8E8E93),
      accent: accentColor,
      accentLight: accentLight,
      accentForeground: accentForeground,
      border: const Color(0xFF38383A),
      borderAccent: accentColor,
      gray100: const Color(0xFF1C1C1E),
    );
  }

  return FeaturamaTheme(
    background: const Color(0xFFF2F2F7),
    card: const Color(0xFFFFFFFF),
    secondary: const Color(0xFFF2F2F7),
    text: const Color(0xFF000000),
    textSecondary: const Color(0xFF8E8E93),
    accent: accentColor,
    accentLight: accentLight,
    accentForeground: accentForeground,
    border: const Color(0xFFE5E5EA),
    borderAccent: accentColor,
    gray100: const Color(0xFFE5E5EA),
  );
}
