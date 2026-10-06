import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF2D2A77),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD9D8F7),
  onPrimaryContainer: Color(0xFF17143D),

  secondary: Color(0xFFE41E26),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDAD9),
  onSecondaryContainer: Color(0xFF410003),

  tertiary: Color(0xFFF0F4F8),
  onTertiary: Color(0xFF1A1A1A),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),

  surface: Color(0xFFF5F7FA),
  onSurface: Color(0xFF1A1A1A),

  outline: Color(0xFFC5CCD6),

  shadow: Colors.black,
  inverseSurface: Color(0xFF2F3136),
  onInverseSurface: Color(0xFFF1F1F1),
  surfaceContainerHighest: Color(0xFFF5F7FA),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: const Color(0xFFA6A2FF),
  onPrimary: const Color(0xFF17143D),
  primaryContainer: const Color(0xFF2D2A77),
  onPrimaryContainer: const Color(0xFFD9D8F7),

  secondary: const Color(0xFFFF6B6F),
  onSecondary: const Color(0xFF4A0003),
  secondaryContainer: const Color(0xFF7D1014),
  onSecondaryContainer: const Color(0xFFFFDAD9),

  tertiary: const Color(0xFF2A3138),
  onTertiary: const Color(0xFFF0F4F8),

  error: const Color(0xFFFFB4AB),
  onError: const Color(0xFF690005),

  surface: const Color(0xFF121212),
  onSurface: const Color(0xFFF0F4F8),

  outline: const Color(0xFF8E96A3),

  shadow: Colors.black,
  inverseSurface: const Color(0xFFF0F4F8),
  onInverseSurface: const Color(0xFF1A1A1A),
  surfaceContainerHighest: const Color(0xFF1E1E1E),
);
