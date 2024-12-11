import 'package:flutter/material.dart';

class CustomColors {
  static Color primaryTextColor = Colors.white;
  static Color dividerColor = Colors.white54;
  static Color pageBackgroundColor = const Color.fromARGB(255, 26, 26, 39);
  static Color clockBackgroundColor = const Color.fromARGB(255, 55, 57, 96);
}

class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> sky = [const Color(0xFF6448FE), const Color(0xFF5FC6FF)];
  static List<Color> sunset = [
    const Color(0xFFFE6197),
    const Color(0xFFFFB463)
  ];
  static List<Color> sea = [const Color(0xFF61A3FE), const Color(0xFF63FFD5)];
  static List<Color> mango = [const Color(0xFFFFA738), const Color(0xFFFFE130)];
  static List<Color> fire = [const Color(0xFFFF5DCD), const Color(0xFFFF8484)];
  static List<Color> ocean = [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
  static List<Color> sunrise = [
    const Color(0xFFFF5F6D),
    const Color(0xFFFFC371)
  ];
  static List<Color> aurora = [
    const Color(0xFF00c6ff),
    const Color(0xFF0072ff)
  ];
  static List<Color> twilight = [
    const Color(0xFF0F2027),
    const Color(0xFF2C5364)
  ];
  static List<Color> tropical = [
    const Color(0xFFf5af19),
    const Color(0xFFf12711)
  ];
  static List<Color> lavender = [
    const Color(0xFFDAE2F8),
    const Color(0xFFD6A4A4)
  ];
  static List<Color> flamingo = [
    const Color(0xFFFE8C00),
    const Color(0xFFF83600)
  ];
  static List<Color> mint = [const Color(0xFF76b852), const Color(0xFF8DC26F)];
  static List<Color> dusk = [const Color(0xFF4E54C8), const Color(0xFF8F94FB)];
}

class GradientTemplate {
  static List<List<Color>> gradientTemplate = [
    GradientColors.sky,
    GradientColors.sunset,
    GradientColors.ocean,
    GradientColors.sunrise,
    GradientColors.aurora,
    GradientColors.twilight,
    GradientColors.tropical,
    GradientColors.lavender,
    GradientColors.flamingo,
    GradientColors.mint,
    GradientColors.dusk,
  ];
}
