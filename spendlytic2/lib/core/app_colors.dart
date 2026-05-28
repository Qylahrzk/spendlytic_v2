import 'package:flutter/material.dart';

class AppColors {
  // 💜 The "Budget Hero" Gradient Colors
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color darkIndigo = Color(0xFF283593);

  // Helper for the Gradient
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPurple, darkIndigo],
  );

  // Keep these for text/backgrounds
  static const Color primaryDark = Color(0xFF6A1B9A);
  // ✅ ADDED THIS BACK (Cyan Pop for Charts)
  static const Color secondary = Color(0xFF69F0AE);

  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF7FAFF);

  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
}
