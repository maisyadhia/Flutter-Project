import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_inherited_widget.dart';
import 'first_screen.dart';
import 'second_screen.dart';

// APLIKASI UTAMA
class ThemeApp extends StatefulWidget {
  @override
  _ThemeAppState createState() => _ThemeAppState();
}

class _ThemeAppState extends State<ThemeApp> {
  AppTheme appTheme = AppTheme();

  void toggleTheme() {
    setState(() {
      appTheme.isDarkMode = !appTheme.isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeInheritedWidget(
      appTheme: appTheme,
      toggleTheme: toggleTheme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme.themeData,
        home: FirstScreen(),
        routes: {
          '/second': (context) => SecondScreen(),
        },
      ),
    );
  }
}

void main() {
  runApp(ThemeApp());
}
