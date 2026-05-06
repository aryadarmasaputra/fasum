import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  String? _base64Image;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUpLoading = false;
  double? _latitude;
  double? _longitude;
  String? _aiCategory;
  String? _aiDescription;
  bool _isGenerating = false;
  List<String> _categories = [
    'Jalan Rusak',
    'Marka Pudar',
    'Lampu Mati',
    'Trotoar Rusak',
    'Rambu Rusak',
    'Jembatan Rusak',
    'Sampah Menumpuk',
    'Saluran Tersumbat',
    'Sungai Tercemar',
    'Sampah Sungai',
    'Pohon Tumbang',
    'Taman Rusak',
    'Fasilitas Rusak',
    'Pipa Bocor',
    'Vandalisme',
    'Banjir',
    'Lainnya',
  ];

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_categories[index]),
              onTap: () {
                setState(() {
                  _aiCategory = _categories[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _aiCategory = null;
        _aiDescription = null;
        _descriptionController.clear();
      });
      await _compressAndEncodeImage();
      await _generateAIDescriptionWithAI();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of{
        context,
      }.showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      }
    }
  }
Future<void> _compressAndEncodeImage() async {
    if (_image == null) return;
    try {
      final compressedImage = await
      flutterImageCompress.compressedWithFile(
        _image!.path,
        quality: 50,
      );
      if (compressedImage == null) return;
      setState(() {
        _base64Image = base64Encode(compressedImage);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

Future<void> _generateDescriptionWithAI() async {
    if (image == null) return;
    setState(() {
      _isGenerating = true;
    });x
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: const Center(child: Text('Add Post Screen')),
    );
  }
}
