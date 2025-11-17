import 'package:flutter/material.dart';

// DATA THEME
class AppTheme {
  bool isDarkMode = false;

  ThemeData get themeData {
    return isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

  Color get backgroundColor {
    return isDarkMode ? Colors.grey[900]! : Colors.white;
  }

  Color get textColor {
    return isDarkMode ? Colors.white : Colors.black;
  }
}
