import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPicturePage extends StatefulWidget {
  final Map<String, dynamic>? pet;
  const UploadPicturePage({super.key, this.pet});

  @override
  State<UploadPicturePage> createState() => _UploadPicturePageState();
}

class _UploadPicturePageState extends State<UploadPicturePage> {
  final _picker = ImagePicker();
  final supabase = Supabase.instance.client;
  File? _file;
  bool _loading = false;

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    setState(() => _file = File(img.path));
  }

  Future<void> _upload() async {
    if (_file == null) return;
    setState(() => _loading = true);
    try {
      final String fileName = 'pet_${widget.pet?['id'] ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String path = 'public/$fileName';
      await supabase.storage.from('pets_profile').upload(path, _file!);
      final publicUrl = supabase.storage.from('pets_profile').getPublicUrl(path);
      // Return the uploaded URL to the caller
      if (mounted) Navigator.of(context).pop(publicUrl);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Pet Picture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: _file == null
                    ? const Text('No image selected')
                    : Image.file(_file!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from gallery'),
                  onPressed: _pickImage,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload),
              label: const Text('Upload'),
              onPressed: _file != null && !_loading ? _upload : null,
            ),
          ],
        ),
      ),
    );
  }
}
