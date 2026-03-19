import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TextRecognizerPage(),
    );
  }
}

class TextRecognizerPage extends StatefulWidget {
  const TextRecognizerPage({super.key});
  @override
  State<TextRecognizerPage> createState() => _TextRecognizerPageState();
}

class _TextRecognizerPageState extends State<TextRecognizerPage> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  File? _selectedImage;
  String _recognizedText = "";
  bool _isScanning = false;
  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isScanning = true;
        _selectedImage = null;
        _recognizedText = "";
      });

      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _scanImage(image.path);
      } else {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showErrorDialog("Error picking image: $e");
    }
  }

  Future<void> _scanImage(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);

      final RecognizedText result = await _textRecognizer.processImage(inputImage);

      setState(() {
        _isScanning = false;
        _recognizedText = result.text;
      });

      if (_recognizedText.isEmpty) {
        _showErrorDialog("No text found in this image.");
      }

    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showErrorDialog("Error recognizing text: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Notice"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Recognizer"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              color: Colors.grey[200],
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.contain)
                  : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 64, color: Colors.grey),
                    Text("No image selected"),
                  ],
                ),
              ),
            ),

            if (_isScanning) const LinearProgressIndicator(),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _showImageSourceSheet,
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Pick Image to Scan"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recognized Text:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _recognizedText.isEmpty
                          ? (_isScanning ? "Scanning..." : "No text detected yet.")
                          : _recognizedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}