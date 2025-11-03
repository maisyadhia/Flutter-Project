import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(CameraApp(cameras: cameras, initialCamera: firstCamera));
}

class CameraApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final CameraDescription initialCamera;

  const CameraApp({super.key, required this.cameras, required this.initialCamera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: CameraScreen(cameras: cameras, camera: initialCamera),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraDescription camera;

  const CameraScreen({super.key, required this.cameras, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription _currentCamera;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera;
    _controller = CameraController(_currentCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    final newCamera = widget.cameras.firstWhere(
      (cam) => cam.lensDirection != _currentCamera.lensDirection,
      orElse: () => _currentCamera,
    );

    setState(() {
      _currentCamera = newCamera;
      _controller = CameraController(_currentCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();
    });
  }

  Future<void> _takePicture(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      // Dapatkan direktori lokal untuk menyimpan file
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Simpan file ke path baru
      await image.saveTo(imagePath);

      setState(() => _imageFile = XFile(imagePath));

      // Tampilkan path foto di Snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto disimpan di: $imagePath')),
        );
      }
    } catch (e) {
      debugPrint('Error mengambil foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Ganti Kamera',
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CameraPreview(_controller),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FloatingActionButton.extended(
                    onPressed: () => _takePicture(context),
                    icon: const Icon(Icons.camera),
                    label: const Text('Ambil Foto'),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: _imageFile != null
          ? Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Path Foto Terakhir: ${_imageFile!.path}',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
    );
  }
}
