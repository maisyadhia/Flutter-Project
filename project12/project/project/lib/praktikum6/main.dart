import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

//--- SERVICE: FileService (Sama seperti Praktikum 5) ---
class FileService {
  Future<Directory> get documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }
  // (Method lain seperti writeFile, readFile, fileExists, deleteFile
  //  dapat disalin dari Praktikum 5 jika diperlukan, 
  //  meskipun praktikum ini tidak menggunakannya secara langsung)
}

//--- SERVICE: DirectoryService (Manajemen direktori) ---
class DirectoryService {
  final FileService _fileService = FileService();

  // Membuat direktori baru jika belum ada
  Future<Directory> createDirectory(String dirName) async {
    final Directory appDir = await _fileService.documentsDirectory;
    final Directory newDir = Directory(path.join(appDir.path, dirName));
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }
    return newDir;
  }
  
  // (Method listFiles dan deleteDirectory ada di slide,
  //  tapi tidak dipakai langsung oleh NoteService)
}

//--- SERVICE: NoteService (Logika bisnis catatan) ---
class NoteService {
  final DirectoryService _dirService = DirectoryService();
  final String _notesDir = 'notes'; // Nama sub-direktori

  // Menyimpan catatan baru
  Future<void> saveNote({
    required String title,
    required String content,
  }) async {
    // Pastikan direktori 'notes' ada
    final Directory notesDir = await _dirService.createDirectory(_notesDir);
    
    // Buat nama file unik berdasarkan timestamp
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.json';
    final File file = File(path.join(notesDir.path, fileName));
    
    final noteData = {
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    // Tulis data JSON ke file
    await file.writeAsString(jsonEncode(noteData));
  }

  // Mengambil semua catatan
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final Directory notesDir = await _dirService.createDirectory(_notesDir);
    final List<FileSystemEntity> files = await notesDir.list().toList();
    List<Map<String, dynamic>> notes = [];
    
    for (var entity in files) {
      // Pastikan itu file dan berakhiran .json
      if (entity is File && entity.path.endsWith('.json')) {
        final content = await entity.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        data['file_path'] = entity.path; // Simpan path file untuk menghapus
        notes.add(data);
      }
    }
    
    // Urutkan dari yang terbaru
    notes.sort(
      (a, b) =>
          b['created_at'].toString().compareTo(a['created_at'].toString()),
    );
    return notes;
  }

  // Menghapus catatan berdasarkan path filenya
  Future<void> deleteNoteByPath(String filePath) async {
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

//--- MAIN APP ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notes (Local File)',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: NotesPage(),
    );
  }
}

//--- UI: Halaman Daftar Catatan (NotesPage) ---
class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NoteService _noteService = NoteService();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Muat semua catatan dari file
  Future<void> _loadNotes() async {
    final notes = await _noteService.getAllNotes();
    setState(() => _notes = notes);
  }

  // Navigasi ke halaman tambah catatan
  Future<void> _addNote() async {
    // Tunggu hasil dari AddNotePage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage()),
    );
    // Jika hasilnya 'true' (berhasil menyimpan), muat ulang catatan
    if (result == true) {
      _loadNotes();
    }
  }

  // Hapus catatan
  Future<void> _deleteNote(String filePath) async {
    await _noteService.deleteNoteByPath(filePath);
    _loadNotes(); // Muat ulang catatan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notes')),
      body: _notes.isEmpty
          ? Center(child: Text('Belum ada catatan.'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(note['title'] ?? 'No Title'),
                    subtitle: Text(
                      note['content'] ?? 'No Content',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note['file_path']),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(note: note),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}

//--- UI: Halaman Tambah Catatan (AddNotePage) ---
class AddNotePage extends StatefulWidget {
  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final NoteService _noteService = NoteService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Isi semua field dulu!')),
        );
      }
      return;
    }

    await _noteService.saveNote(
      title: _titleController.text,
      content: _contentController.text,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan disimpan!')),
      );
      Navigator.pop(context, true); // Kembali ke halaman list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catatan Baru')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Judul'),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Isi Catatan',
                  alignLabelWithHint: true
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Simpan'),
              onPressed: _saveNote,
            ),
          ],
        ),
      ),
    );
  }
}

//--- UI: Halaman Detail Catatan (NoteDetailPage) ---
class NoteDetailPage extends StatelessWidget {
  final Map<String, dynamic> note;
  const NoteDetailPage({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note['title'] ?? 'Note')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView( // Agar bisa di-scroll jika teks panjang
          child: Text(note['content'] ?? ''),
        ),
      ),
    );
  }
}