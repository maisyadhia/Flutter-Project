// SCREEN PERTAMA
import 'package:flutter/material.dart';
import 'theme_inherited_widget.dart'; // pastikan file ini ada
import 'second_screen.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeInherited = ThemeInheritedWidget.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pengajuan Surat'),
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Formulir Data Diri',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeInherited?.appTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Input Nama
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Input NIP
                TextFormField(
                  controller: _nipController,
                  decoration: const InputDecoration(
                    labelText: 'NIP / ID Pegawai',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIP wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Input Jabatan
                TextFormField(
                  controller: _jabatanController,
                  decoration: const InputDecoration(
                    labelText: 'Jabatan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jabatan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Submit
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SecondScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text('Lanjut ke Daftar Surat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}