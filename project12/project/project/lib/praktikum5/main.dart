import 'dart:convert'; // Dibutuhkan untuk jsonEncode/Decode
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

//--- SERVICE: FileService (Operasi file dasar) ---
class FileService {
  // Mendapatkan direktori dokumen internal aplikasi
  Future<Directory> get documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  // Menulis String ke file
  Future<File> writeFile(String fileName, String content) async {
    final Directory dir = await documentsDirectory;
    final File file = File(path.join(dir.path, fileName));
    return file.writeAsString(content);
  }

  // Membaca String dari file
  Future<String> readFile(String fileName) async {
    try {
      final Directory dir = await documentsDirectory;
      final File file = File(path.join(dir.path, fileName));
      return await file.readAsString();
    } catch (e) {
      return ''; // Kembalikan string kosong jika file tidak ada/error
    }
  }

  // Menulis Map (JSON) ke file
  Future<File> writeJson(String fileName, Map<String, dynamic> json) async {
    final String content = jsonEncode(json); // Konversi Map ke String JSON
    return writeFile(fileName, content);
  }

  // Membaca JSON (Map) dari file
  Future<Map<String, dynamic>> readJson(String fileName) async {
    try {
      final String content = await readFile(fileName);
      if (content.isEmpty) return {};
      return jsonDecode(content); // Konversi String JSON ke Map
    } catch (e) {
      return {};
    }
  }

  // Cek keberadaan file
  Future<bool> fileExists(String fileName) async {
    final Directory dir = await documentsDirectory;
    final File file = File(path.join(dir.path, fileName));
    return file.exists();
  }

  // Menghapus file
  Future<void> deleteFile(String fileName) async {
    try {
      final Directory dir = await documentsDirectory;
      final File file = File(path.join(dir.path, fileName));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}

//--- SERVICE: UserDataService (Logika bisnis data user) ---
class UserDataService {
  final FileService _fileService = FileService();
  final String _fileName = 'user_data.json'; // Nama file untuk data user

  // Menyimpan data user
  Future<void> saveUserData({
    required String name,
    required String email,
    int? age,
  }) async {
    final Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'age': age ?? 0,
      'last_update': DateTime.now().toIso8601String(),
    };
    await _fileService.writeJson(_fileName, userData);
  }

  // Membaca data user
  Future<Map<String, dynamic>?> readUserData() async {
    final exists = await _fileService.fileExists(_fileName);
    if (!exists) return null;
    
    final Map<String, dynamic> data = await _fileService.readJson(_fileName);
    return data.isNotEmpty ? data : null;
  }

  // Menghapus data user
  Future<void> deleteUserData() async {
    await _fileService.deleteFile(_fileName);
  }
}

//--- MAIN APP ---
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib untuk path_provider
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Data JSON Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: UserProfilePage(),
    );
  }
}

//--- UI PAGE ---
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserDataService _userService = UserDataService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  Map<String, dynamic>? _savedData; // State untuk data yang tersimpan

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Memuat data dari file JSON
  Future<void> _loadUserData() async {
    final data = await _userService.readUserData();
    setState(() {
      _savedData = data;
      // Isi controller jika data ada
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _ageController.text = (data['age'] ?? 0).toString();
      } else {
        // Bersihkan controller jika data tidak ada
        _nameController.clear();
        _emailController.clear();
        _ageController.clear();
      }
    });
  }

  // Menyimpan data ke file JSON
  Future<void> _saveUserData() async {
    await _userService.saveUserData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
    );
    
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan')),
      );
    }
    await _loadUserData(); // Muat ulang data
  }

  // Menghapus file JSON
  Future<void> _deleteUserData() async {
    await _userService.deleteUserData();
    await _loadUserData(); // Muat ulang (akan mengosongkan state)
    
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data user dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil User (File JSON)')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // --- FORM INPUT ---
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Usia',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            
            // --- BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Simpan'),
                  onPressed: _saveUserData,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _deleteUserData,
                ),
              ],
            ),
            SizedBox(height: 30),
            Divider(),
            
            // --- TAMPILAN DATA YANG DISIMPAN ---
            _savedData == null
                ? Text(
                    'Belum ada data tersimpan.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column( // Tampilkan data jika ada
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Tersimpan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDataRow('Nama', _savedData!['name'] ?? '-'),
                      _buildDataRow('Email', _savedData!['email'] ?? '-'),
                      _buildDataRow('Usia', _savedData!['age']?.toString() ?? '-'),
                      _buildDataRow(
                        'Update Terakhir',
                        _savedData!['last_update'] ?? '-',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan 1 baris data
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}