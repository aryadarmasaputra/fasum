// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:http/http.dart' as http;

// class AddPostScreen extends StatefulWidget {
//   const AddPostScreen({super.key});

//   @override
//   State<AddPostScreen> createState() => _AddPostScreenState();
// }

// class _AddPostScreenState extends State<AddPostScreen> {
//   File? _image;
//   String? _base64Image;
//   final TextEditingController _descriptionController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;
//   double? _latitude;
//   double? _longitude;
//   String? _aiCategory;
//   String? _aiDescription;
//   bool _isGeneratingAI = false;
//   List<String> _categories = [
//     'Jalan Rusak',
//     'Marka Pudar',
//     'Lampu Mati',
//     'Trotoar Rusak',
//     'Rambu Rusak',
//     'Jembatan Rusak',
//     'Sampah Menumpuk',
//     'Saluran Tersumbat',
//     'Sungai Tercemar',
//     'Sampah Sungai',
//     'Pohon Tumbang',
//     'Taman Rusak',
//     'Fasilitas Umum Rusak',
//     'Pipa Bocor',
//     'Vadalisme',
//     'Banjir',
//     'Lainnya',
//   ];

//   void _showCategorySelection() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return ListView(
//           shrinkWrap: true,
//           children: _categories.map((category) {
//             return ListTile(
//               title: Text(category),
//               onTap: () {
//                 setState(() {
//                   _aiCategory = category;
//                 });
//                 Navigator.pop(context);
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _aiCategory = null;
//           _aiDescription = null;
//           _descriptionController.clear();
//         });
//         await _compressAndEncodeImage();
//         await _generateDescriptionWithAI();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
//       }
//     }
//   }

//   Future<void> _compressAndEncodeImage() async {
//     if (_image == null) return;
//     try {
//       final compressedImage = await FlutterImageCompress.compressWithFile(
//         _image!.path,
//         quality: 50,
//       );
//       if (compressedImage != null) {
//         setState(() {
//           _base64Image = base64Encode(compressedImage);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error compressing image: $e')));
//       }
//     }
//   }

//   Future<void> _generateDescriptionWithAI() async {
//     if (_image == null) return;
//     setState(() => _isGeneratingAI = true);
//     try {
//       final imageBytes = await _image!.readAsBytes();
//       final base64Image = base64Encode(imageBytes);
//       const apiKey =
//           'AIzaSyC7gqszgh_PThCTXmYsvMheIQxodz7FdbA'; // ganti dengan API key kamu
//       const url =
//           'https://generativelanguage.googleapis.com/v1/models/'
//           'gemini-2.0-flash:generateContent?key=$apiKey';
//       final body = jsonEncode({
//         "contents": [
//           {
//             "parts": [
//               {
//                 "inlineData": {"mimeType": "image/jpeg", "data": base64Image},
//               },
//               {
//                 "text":
//                     "Berdasarkan foto ini, identifikasi satu kategori utama kerusakan fasilitas umum "
//                     "dari daftar berikut: Jalan Rusak, Marka Pudar, Lampu Mati, Trotoar Rusak, "
//                     "Rambu Rusak, Jembatan Rusak, Sampah Menumpuk, Saluran Tersumbat, Sungai Tercemar, "
//                     "Sampah Sungai, Pohon Tumbang, Taman Rusak, Fasilitas Rusak, Pipa Bocor, "
//                     "Vandalisme, Banjir, dan Lainnya. "
//                     "Pilih kategori yang paling dominan atau paling mendesak untuk dilaporkan. "
//                     "Buat deskripsi singkat untuk laporan perbaikan, dan tambahkan permohonan perbaikan. "
//                     "Fokus pada kerusakan yang terlihat dan hindari spekulasi.\n\n"
//                     "Format output yang diinginkan:\n"
//                     "Kategori: [satu kategori yang dipilih]\n"
//                     "Deskripsi: [deskripsi singkat]",
//               },
//             ],
//           },
//         ],
//       });
//       final headers = {'Content-Type': 'application/json'};
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: body,
//       );
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final text =
//             jsonResponse['candidates'][0]['content']['parts'][0]['text'];
//         print("AI TEXT: $text");
//         if (text != null && text.isNotEmpty) {
//           final lines = text.trim().split('\n');
//           String? category;
//           String? description;
//           for (var line in lines) {
//             final lower = line.toLowerCase();
//             if (lower.startsWith('kategori:')) {
//               category = line.substring(9).trim();
//             } else if (lower.startsWith('deskripsi:')) {
//               description = line.substring(10).trim();
//             } else if (lower.startsWith('keterangan:')) {
//               description = line.substring(11).trim();
//             }
//           }
//           description ??= text.trim();
//           setState(() {
//             _aiCategory = category ?? 'Tidak diketahui';
//             _aiDescription = description!;
//             _descriptionController.text = _aiDescription!;
//           });
//         }
//       } else {
//         debugPrint('Request failed: ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('Failed to generate AI description: $e');
//     } finally {
//       if (mounted) setState(() => _isGeneratingAI = false);
//     }
//   }

//   Future<void> _getLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location services are disabled.')),
//         );
//         return;
//       }
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.deniedForever ||
//             permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Location permissions are denied.')),
//           );
//           return;
//         }
//       }
//       final position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//         ),
//       ).timeout(const Duration(seconds: 10));
//       setState(() {
//         _latitude = position.latitude;
//         _longitude = position.longitude;
//       });
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
//       setState(() {
//         _latitude = null;
//         _longitude = null;
//       });
//     }
//   }

//   void _showImageSourceActionSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Take a Picture'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Select from Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.cancel),
//                 title: const Text('Cancel'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _submitPost() async {
//     if (_base64Image == null || _descriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please select an image and provide a description before submitting.',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _isUploading = true;
//     });
//     final now = DateTime.now().toIso8601String();
//     final vid = FirebaseAuth.instance.currentUser?.uid;
//     if (vid == null) {
//       setState(() {
//         _isUploading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('User not authenticated. Please sign in again.'),
//         ),
//       );

//       return;
//     }
//     try {
//       await _getLocation();
//       final userDov = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(vid)
//           .get();
//       final fullName = userDov.data()?['fullName'] ?? 'Unknown User';
//       await FirebaseFirestore.instance.collection('posts').add({
//         'image': _base64Image,
//         'description': _descriptionController.text.trim(),
//         'createdAt': now,
//         'fullName': fullName,
//         'latitude': _latitude,
//         'longitude': _longitude,
//         'category': _aiCategory ?? 'Lainnya',
//         'userId': vid,
//       });
//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Post submitted successfully!')),
//       );
//     } catch (e) {
//       debugPrint('Error submitting post: $e');
//       if (!mounted) return;
//       setState(() {
//         _isUploading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error submitting post: $e')));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add New Post')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             GestureDetector(
//               onTap: _showImageSourceActionSheet,
//               child: Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: _image != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           _image!.path,
//                           height: 250,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : const Center(
//                         child: Icon(
//                           Icons.add_a_photo,
//                           size: 50,
//                           color: Colors.grey,
//                         ),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (_isGeneratingAI)
//               Shimmer.fromColors(
//                 baseColor: Colors.grey[300]!,
//                 highlightColor: Colors.grey[100]!,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 100,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 12),
//                     ),
//                     Container(
//                       width: double.infinity,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             if (_aiCategory != null && !_isGeneratingAI)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: _showCategorySelection,
//                       child: Chip(
//                         label: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(_aiCategory!),
//                             const SizedBox(width: 6),
//                             const Icon(Icons.edit, size: 16),
//                           ],
//                         ),
//                         backgroundColor: Colors.blue[100],
//                       ),
//                     ),
//                     if (_image != null)
//                       IconButton(
//                         onPressed: _generateDescriptionWithAI,
//                         icon: const Icon(Icons.refresh),
//                         tooltip: 'Regenerate AI Description',
//                       ),
//                   ],
//                 ),
//               ),
//             Offstage(
//               offstage: _isGeneratingAI,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   TextField(
//                     controller: _descriptionController,
//                     textCapitalization: TextCapitalization.sentences,
//                     maxLines: 6,
//                     decoration: const InputDecoration(
//                       hintText: 'Add a brief description',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             ElevatedButton(
//               onPressed: _isUploading ? null : _submitPost,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 textStyle: const TextStyle(fontSize: 16),
//                 backgroundColor: Colors.green,
//               ),
//               child: _isUploading
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Text('post', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // ✅ Gunakan Uint8List agar kompatibel di Web & Mobile
  Uint8List? _imageBytes;
  String? _base64Image;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double? _latitude;
  double? _longitude;
  String? _aiCategory;
  String? _aiDescription;
  bool _isGeneratingAI = false;

  final List<String> _categories = [
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
    'Fasilitas Umum Rusak',
    'Pipa Bocor',
    'Vandalisme',
    'Banjir',
    'Lainnya',
  ];

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: _categories.map((category) {
            return ListTile(
              title: Text(category),
              onTap: () {
                setState(() => _aiCategory = category);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        // ✅ readAsBytes() bekerja di Web & Mobile
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _base64Image = base64Encode(bytes);
          _aiCategory = null;
          _aiDescription = null;
          _descriptionController.clear();
        });
        await _generateDescriptionWithAI();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _generateDescriptionWithAI() async {
    if (_imageBytes == null) return;
    setState(() => _isGeneratingAI = true);
    try {
      // ✅ Gunakan _imageBytes langsung, bukan _image!.readAsBytes()
      final base64Image = base64Encode(_imageBytes!);
      const apiKey = 'AIzaSyC7gqszgh_PThCTXmYsvMheIQxodz7FdbA';
      const url =
          'https://generativelanguage.googleapis.com/v1/models/'
          'gemini-2.0-flash:generateContent?key=$apiKey';

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "inlineData": {"mimeType": "image/jpeg", "data": base64Image},
              },
              {
                "text":
                    "Berdasarkan foto ini, identifikasi satu kategori utama kerusakan fasilitas umum "
                    "dari daftar berikut: Jalan Rusak, Marka Pudar, Lampu Mati, Trotoar Rusak, "
                    "Rambu Rusak, Jembatan Rusak, Sampah Menumpuk, Saluran Tersumbat, Sungai Tercemar, "
                    "Sampah Sungai, Pohon Tumbang, Taman Rusak, Fasilitas Rusak, Pipa Bocor, "
                    "Vandalisme, Banjir, dan Lainnya. "
                    "Pilih kategori yang paling dominan atau paling mendesak untuk dilaporkan. "
                    "Buat deskripsi singkat untuk laporan perbaikan, dan tambahkan permohonan perbaikan. "
                    "Fokus pada kerusakan yang terlihat dan hindari spekulasi.\n\n"
                    "Format output yang diinginkan:\n"
                    "Kategori: [satu kategori yang dipilih]\n"
                    "Deskripsi: [deskripsi singkat]",
              },
            ],
          },
        ],
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        if (text != null && text.isNotEmpty) {
          final lines = (text as String).trim().split('\n');
          String? category;
          String? description;
          for (var line in lines) {
            final lower = line.toLowerCase();
            if (lower.startsWith('kategori:')) {
              category = line.substring(9).trim();
            } else if (lower.startsWith('deskripsi:')) {
              description = line.substring(10).trim();
            } else if (lower.startsWith('keterangan:')) {
              description = line.substring(11).trim();
            }
          }
          description ??= text.trim();
          setState(() {
            _aiCategory = category ?? 'Tidak diketahui';
            _aiDescription = description!;
            _descriptionController.text = _aiDescription!;
          });
        }
      } else {
        debugPrint('Request failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to generate AI description: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _latitude = null;
        _longitude = null;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitPost() async {
    // ✅ Validasi menggunakan _imageBytes dan _base64Image
    if (_imageBytes == null || _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu.')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi deskripsi sebelum mengirim.'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final now = DateTime.now().toIso8601String();
    final vid = FirebaseAuth.instance.currentUser?.uid;
    if (vid == null) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Please sign in again.'),
        ),
      );
      return;
    }

    try {
      await _getLocation();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(vid)
          .get();
      final fullName = userDoc.data()?['fullName'] ?? 'Unknown User';

      await FirebaseFirestore.instance.collection('posts').add({
        'image': _base64Image,
        'description': _descriptionController.text.trim(),
        'createdAt': now,
        'fullName': fullName,
        'latitude': _latitude,
        'longitude': _longitude,
        'category': _aiCategory ?? 'Lainnya',
        'userId': vid,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully!')),
      );
    } catch (e) {
      debugPrint('Error submitting post: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting post: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showImageSourceActionSheet,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                // ✅ Image.memory() bekerja di Web & Mobile
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _imageBytes!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isGeneratingAI)
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            if (_aiCategory != null && !_isGeneratingAI)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showCategorySelection,
                      child: Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_aiCategory!),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit, size: 16),
                          ],
                        ),
                        backgroundColor: Colors.blue[100],
                      ),
                    ),
                    if (_imageBytes != null)
                      IconButton(
                        onPressed: _generateDescriptionWithAI,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Regenerate AI Description',
                      ),
                  ],
                ),
              ),
            Offstage(
              offstage: _isGeneratingAI,
              child: TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan deskripsi singkat',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: Colors.green,
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
