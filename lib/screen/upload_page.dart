import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? _imageBytes;
  String? _fileName;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;
  int _selectedIndex = 2;

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        PlatformFile file = result.files.single;
        if (file.bytes != null) {
          setState(() {
            _imageBytes = file.bytes;
            _fileName = file.name;
          });
        } else if (file.path != null) {
          final File imageFile = File(file.path!);
          final Uint8List bytes = await imageFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _fileName = file.name;
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null || _titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showErrorDialog('Please provide an image, title, and description.');
      return;
    }
    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String fileExtension = _fileName!.split('.').last.toLowerCase();

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('uploads/$fileName.$fileExtension')
          .putData(_imageBytes!);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await FirebaseFirestore.instance.collection('photos').add({
        'judulFoto': _titleController.text,
        'deskripsiFoto': _descriptionController.text,
        'imageUrl': downloadUrl,
        'userId': userId,
        'tanggalUnggah': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog('Upload failed: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/upload');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/notifikasi');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Your Image',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField("Title", _titleController),
            SizedBox(height: 16),
            _buildTextField("Description", _descriptionController),
            SizedBox(height: 16),
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 200, fit: BoxFit.cover)
                : Text("No image selected", style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            _buildButton("Pick Image", _pickImage),
            SizedBox(height: 16),
            _buildButton("Upload", _uploadImage, isLoading: _isUploading),
          ],
        ),
      ),
     bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF1E1B22),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, color: Colors.white, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        elevation: 0,
      ),
    );
  }
}

Widget _buildTextField(String label, TextEditingController controller) {
  return TextField(
    controller: controller,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

Widget _buildButton(String text, VoidCallback onPressed, {bool isLoading = false}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      minimumSize: Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: isLoading
        ? CircularProgressIndicator(color: Colors.black)
        : Text(text, style: TextStyle(color: Colors.black)),
  );
}
