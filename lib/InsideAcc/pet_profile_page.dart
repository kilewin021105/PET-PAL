import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'upload_picture_page.dart';

class PetProfileScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  const PetProfileScreen({super.key, required this.pet});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final supabase = Supabase.instance.client;
  late Map<String, dynamic> pet;
  

  // Preset avatars removed: only gallery upload is supported
  final List<String> avatarUrls = const [];

  @override
  void initState() {
    super.initState();
    pet = Map<String, dynamic>.from(widget.pet);
    _refreshFromDb();
  }

  Future<void> _refreshFromDb() async {
    if (pet['id'] == null) return;
    try {
      final row = await supabase.from('pets').select().eq('id', pet['id']).maybeSingle();
      if (row == null) return;
      setState(() => pet = Map<String, dynamic>.from(row));
    } catch (_) {
      // keep passed-in pet on error
    }
  }

  

  // Image picking/upload flow moved to UploadPicturePage. _uploadImageToStorage and
  // _updatePetPhotoUrl are kept here for compatibility if needed elsewhere.

  Future<void> _updatePetPhotoUrl(String photoUrl) async {
    final List<String> candidates = [
      'photo_url',
      'photo',
      'avatar',
      'avatar_url',
      'image_url',
      'image',
      'photoUrl',
      'url',
    ];
    String column = candidates.firstWhere((k) => pet.containsKey(k), orElse: () => 'photo_url');
    final updatePayload = <String, dynamic>{column: photoUrl};

    try {
      dynamic updated;
      try {
        updated = await supabase.from('pets').update(updatePayload).eq('id', pet['id']).select().maybeSingle();
      } catch (inner) {
        final res = await supabase.from('pets').update(updatePayload).eq('id', pet['id']).select();
        if ((res as List).isEmpty) throw Exception('Update returned empty');
        updated = (res as List).first;
      }

      if (updated == null) throw Exception('Update failed');
      setState(() => pet = Map<String, dynamic>.from(updated as Map<String, dynamic>));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated')));
    } catch (e) {
      final msg = e.toString();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $msg')));
    }
  }

  // Navigation now goes to a dedicated UploadPicturePage; _pickAndUploadImage remains

  Future<void> _editPet() async {
    // Placeholder: refresh from db directly
    await _refreshFromDb();
  }

  @override
  Widget build(BuildContext context) {
    final String name = (pet['name'] ?? 'Pet').toString();
    final String type = (pet['type'] ?? 'Unknown').toString();
    final String species = (pet['species'] ?? 'Unknown').toString();
    final String age = (pet['age']?.toString() ?? 'N/A').toString();
    final String color = (pet['color'] ?? 'N/A').toString();
    final String gender = (pet['gender'] ?? 'N/A').toString();
    final String description = (pet['description'] ?? 'No description').toString();
    final String? photoUrl = pet['photo_url'] as String?;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData genderIcon;
    switch (gender.toLowerCase()) {
      case 'male':
        genderIcon = Icons.male;
        break;
      case 'female':
        genderIcon = Icons.female;
        break;
      default:
        genderIcon = Icons.transgender;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$name's Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit Pet', onPressed: _editPet),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Stack(children: [
              CircleAvatar(
                radius: 64,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.pets, size: 48, color: Colors.grey) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  shape: const CircleBorder(),
                  color: Colors.teal,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                    if (img == null) return;

                    final file = File(img.path);

                    try {
                      final petId = pet['id'] ?? 'unknown';
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final String fileName = 'pet_${petId}_$timestamp.png';
                      final String path = 'public/$fileName';

                      await supabase.storage.from('pets_profile').upload(path, file);
                      final publicUrl = supabase.storage.from('pets_profile').getPublicUrl(path);

                      await _updatePetPhotoUrl(publicUrl);
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                    }
                  },
                    child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.camera_alt, color: Colors.white)),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Center(child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
            Chip(
              avatar: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.category, size: 18, color: Colors.teal),
              ),
              label: Text(type),
            ),
            Chip(
              avatar: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.pets, size: 18, color: Colors.teal),
              ),
              label: Text(species),
            ),
            Chip(
              avatar: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.cake_outlined, size: 18, color: Colors.teal),
              ),
              label: Text("$age yrs"),
            ),
          ]),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
            child: Column(children: [
              _infoTile('Breed/Species', species, Icons.pets),
              const Divider(height: 1),
              _infoTile('Age', "$age years", Icons.cake_outlined),
              const Divider(height: 1),
              _infoTile('Color', color, Icons.color_lens_outlined),
              const Divider(height: 1),
              _infoTile('Gender', gender, genderIcon),
            ]),
          ),
          const SizedBox(height: 16),
          Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)),
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),
        ]),
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}