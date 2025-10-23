import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _imageFile;
  final picker = ImagePicker();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    final name = prefs.getString('profile_name') ?? '';
    final email = prefs.getString('profile_email') ?? '';

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() => _imageFile = File(imagePath));
    }

    nameController.text = name;
    emailController.text = email;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = basename(pickedFile.path);
    final savedImage = await File(
      pickedFile.path,
    ).copy('${directory.path}/$fileName');

    setState(() {
      _imageFile = savedImage;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', nameController.text);
    await prefs.setString('profile_email', emailController.text);
    if (_imageFile != null) {
      await prefs.setString('profile_image', _imageFile!.path);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context as BuildContext,
    ).showSnackBar(const SnackBar(content: Text("Profile Saved ✅")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
