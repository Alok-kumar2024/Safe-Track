import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryIndigo = Color(0xFF4F46E5);

  static const LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFFEC4899), // Pink
        Color(0xFF9333EA), // Purple
        Color(0xFF4F46E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight) ;
}