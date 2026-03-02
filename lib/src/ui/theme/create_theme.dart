import 'dart:math';
import 'package:flutter/widgets.dart';
import 'featurama_theme.dart';

List<double> _colorToHsl(Color color) {
  final r = color.red / 255;
  final g = color.green / 255;
  final b = color.blue / 255;

  final cMax = max(r, max(g, b));
  final cMin = min(r, min(g, b));
  double h = 0, s = 0;
  final l = (cMax + cMin) / 2;

  if (cMax != cMin) {
    final d = cMax - cMin;
    s = l > 0.5 ? d / (2 - cMax - cMin) : d / (cMax + cMin);
    if (cMax == r) {
      h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
    } else if (cMax == g) {
      h = ((b - r) / d + 2) / 6;
    } else {
      h = ((r - g) / d + 4) / 6;
    }
  }

  return [(h * 360).roundToDouble(), (s * 100).roundToDouble(), (l * 100).roundToDouble()];
}

Color _hslToColor(double h, double s, double l) {
  s /= 100;
  l /= 100;
  final a = s * min(l, 1 - l);
  double f(double n) {
    final k = (n + h / 30) % 12;
    return l - a * max(min(k - 3, min(9 - k, 1.0)), -1.0);
  }
  return Color.fromARGB(255, (f(0) * 255).round(), (f(8) * 255).round(), (f(4) * 255).round());
}

double _relativeLuminance(Color c) {
  double channel(int v) {
    final s = v / 255;
    return s <= 0.03928 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4).toDouble();
  }
  return 0.2126 * channel(c.red) + 0.7152 * channel(c.green) + 0.0722 * channel(c.blue);
}

FeaturamaTheme createTheme(Color accentColor, Brightness brightness) {
  final hsl = _colorToHsl(accentColor);
  final h = hsl[0];
  final s = hsl[1];
  final isDark = brightness == Brightness.dark;

  final accentLight = isDark
      ? _hslToColor(h, min(s, 30), 20)
      : _hslToColor(h, min(s, 40), 92);

  final accentForeground =
      _relativeLuminance(accentColor) > 0.4 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

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
