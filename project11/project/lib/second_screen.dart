// SCREEN KEDUA
import 'package:flutter/material.dart';
import 'theme_inherited_widget.dart'; // pastikan file ini ada

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeInherited = ThemeInheritedWidget.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 2'),
        actions: [
          IconButton(
            icon: Icon(
              themeInherited?.appTheme.isDarkMode == true
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: themeInherited?.toggleTheme,
          ),
        ],
      ),
      body: Container(
        color: themeInherited?.appTheme.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Screen Kedua',
                style: TextStyle(
                  fontSize: 24,
                  color: themeInherited?.appTheme.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Theme sama di semua screen!',
                style: TextStyle(
                  color: themeInherited?.appTheme.textColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
