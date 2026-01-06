import 'package:flutter/material.dart';

/// Centralized app colors for consistent theming
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Purple

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;

  // Sticky Note Colors (Pastel)
  static const Color noteMintGreen = Color(0xFFB5EAD7);
  static const Color noteLavender = Color(0xFFE0BBE4);
  static const Color noteYellow = Color(0xFFFDECB3);
  static const Color notePeach = Color(0xFFFFDAB9);
  static const Color noteBlue = Color(0xFFB4E7F5);
  static const Color notePink = Color(0xFFFFB3BA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF2D3748);
  static const Color textGrey = Color(0xFF64748B);

  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Border & Divider Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFCBD5E1);

  // List of sticky note colors for rotation
  static const List<Color> stickyNoteColors = [
    noteMintGreen,
    noteLavender,
    noteYellow,
    notePeach,
    noteBlue,
    notePink,
  ];

  // Helper method to get sticky note color by index
  static Color getStickyNoteColor(int index) {
    return stickyNoteColors[index % stickyNoteColors.length];
  }
}
