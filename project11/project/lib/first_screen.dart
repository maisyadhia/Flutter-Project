// SCREEN PERTAMA
import 'package:flutter/material.dart';
import 'theme_inherited_widget.dart'; // pastikan file ini ada

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeInherited = ThemeInheritedWidget.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 1'),
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
                'Screen Pertama',
                style: TextStyle(
                  fontSize: 24,
                  color: themeInherited?.appTheme.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                themeInherited?.appTheme.isDarkMode == true
                    ? 'Mode Gelap'
                    : 'Mode Terang',
                style: TextStyle(
                  color: themeInherited?.appTheme.textColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
                child: const Text('Pergi ke Screen 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
