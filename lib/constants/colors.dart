import 'package:flutter/material.dart';

class AppColors {
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.white;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey[800]!;
  }
}
