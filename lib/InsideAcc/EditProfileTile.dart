import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _avatarUrl; // public URL to the profile picture

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ----------------------------------
  // LOAD PROFILE FROM SUPABASE
  // ----------------------------------
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted || response == null) return;

      setState(() {
        nameController.text = (response['name'] ?? response['fullname'] ?? '').toString();
        emailController.text = (response['email'] ?? '').toString();
        // Try common keys for avatar url
        _avatarUrl = (response['avatar_url'] ?? response['photo_url'] ?? response['image_url'] ?? '').toString();
        if (_avatarUrl != null && _avatarUrl!.isEmpty) _avatarUrl = null;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  // ----------------------------------
  // SAVE PROFILE TO SUPABASE
  // ----------------------------------
  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'name': nameController.text,
        'email': emailController.text,
        'avatar_url': _avatarUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Saved to Supabase ✅")),
      );
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  // ----------------------------------
  // PICK & UPLOAD PROFILE PHOTO
  // ----------------------------------
  Future<void> _pickAndUploadProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final File file = File(image.path);
    final String fileName = 'user_${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
    final String storagePath = 'public/$fileName';

    try {
      // Upload to the 'profile-pictures' bucket
      await supabase.storage.from('profile-pictures').upload(storagePath, file);
      final String publicUrl = supabase.storage.from('profile-pictures').getPublicUrl(storagePath);

      // Update state and persist to profile row
      setState(() => _avatarUrl = publicUrl);

      try {
        await supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);
      } catch (_) {
        // Fallback to upsert just in case the row doesn't exist yet
        await supabase.from('profiles').upsert({'id': user.id, 'avatar_url': publicUrl});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  // ----------------------------------
  // UI
  // ----------------------------------
  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = _avatarUrl != null && _avatarUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Avatar Photo (tap to upload)
            Center(
              child: GestureDetector(
                onTap: _pickAndUploadProfilePhoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: hasAvatar ? NetworkImage(_avatarUrl!) : null,
                  child: hasAvatar
                      ? null
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.teal.shade900,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Name Field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Email Field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // SAVE BUTTON
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
