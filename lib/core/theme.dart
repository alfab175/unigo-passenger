import 'package:flutter/material.dart';

class UnigoTheme {
  static const purple = Color(0xFF6C35DE);
  static ThemeData light() => ThemeData(useMaterial3: true, brightness: Brightness.light, scaffoldBackgroundColor: const Color(0xFFFAFAFC), colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.light), fontFamily: 'Inter');
  static ThemeData dark() => ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF08080A), colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark), fontFamily: 'Inter');
}
