import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokeApp());
}

class PokeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeAPI Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  @override
  _PokemonPageState createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  Map<String, dynamic>? _pokemonData; // State untuk data Pokemon
  bool _isLoading = false;
  String? _error;

  // Fungsi untuk mengambil data dari PokeAPI
  Future<void> fetchPokemon() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pokemonData = null; // Kosongkan data lama saat refresh
    });

    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/ditto'))
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _pokemonData = jsonDecode(response.body); // Simpan data Map
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPokemon(); // Ambil data saat halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PokeAPI - Ditto')),
      body: Center(
        // Panggil widget helper untuk menampilkan data
        child: _buildPokemonCard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchPokemon, // Panggil fetchPokemon saat di-tap
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }

  // Widget helper untuk membangun tampilan data
  Widget _buildPokemonCard() {
    // Tampilkan loading indicator
    if (_isLoading) {
      return CircularProgressIndicator();
    }

    // Tampilkan pesan error
    if (_error != null) {
      return Text(_error!, style: TextStyle(color: Colors.red));
    }

    // Tampilkan data jika berhasil
    if (_pokemonData != null) {
      // Ambil data dari Map
      final name = _pokemonData!['name'] ?? 'N/A';
      final id = _pokemonData!['id'] ?? '-';
      final height = _pokemonData!['height'] ?? '-';
      final weight = _pokemonData!['weight'] ?? '-';
      // Akses nested Map untuk gambar
      final sprite =
          _pokemonData!['sprites']?['front_default'] ??
          'https://via.placeholder.com/150'; // Gambar fallback

      return Card(
        margin: EdgeInsets.all(20),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Sesuaikan ukuran Card
            children: [
              Image.network(sprite, width: 150, height: 150),
              SizedBox(height: 10),
              Text(
                name.toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 8),
              Text('ID: $id'),
              Text('Height: $height'),
              Text('Weight: $weight'),
            ],
          ),
        ),
      );
    }

    // Tampilan default jika tidak loading, tidak error, tapi data null
    return Text('Tekan tombol refresh untuk mengambil data.');
  }
}