import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetProfileScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  const PetProfileScreen({super.key, required this.pet});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final supabase = Supabase.instance.client;
  late Map<String, dynamic> pet;

  // List of predefined avatar URLs
  final List<String> avatarUrls = [
    'https://via.placeholder.com/150/FF0000/FFFFFF?text=Dog1',
    'https://via.placeholder.com/150/00FF00/FFFFFF?text=Dog2',
    'https://via.placeholder.com/150/0000FF/FFFFFF?text=Cat1',
    'https://via.placeholder.com/150/FFFF00/FFFFFF?text=Cat2',
    'https://via.placeholder.com/150/FF00FF/FFFFFF?text=Bird1',
    'https://via.placeholder.com/150/00FFFF/FFFFFF?text=Bird2',
    // Add more as needed
  ];

  @override
  void initState() {
    super.initState();
    pet = Map<String, dynamic>.from(widget.pet);
    _refreshFromDb();
  }

  Future<void> _refreshFromDb() async {
    if (pet['id'] == null) return;
    try {
      // For supabase-dart >= 1.0 use maybeSingle()/single()
      final row = await supabase.from('pets').select().eq('id', pet['id']).maybeSingle();
      if (row == null) return;
      setState(() => pet = Map<String, dynamic>.from(row as Map<String, dynamic>));
    } catch (_) {
      // keep passed-in pet on error
    }
  }

  // Simplified, compatible upload helper (use File upload only)
  Future<String> _uploadFileToStorage(File file, String bucket, String remotePath) async {
    try {
      // Upload File object (widely supported by supabase_flutter v2.x)
      await supabase.storage.from(bucket).upload(remotePath, file, fileOptions: const FileOptions(upsert: true));
    } catch (e) {
      throw Exception('Upload failed: $e');
    }

    // Get public URL (handle string or object shapes)
    final pub = await supabase.storage.from(bucket).getPublicUrl(remotePath);
    if (pub is String) return pub;
  }

  Future<void> _promptAddPhoto() async {
    final String? selectedAvatar = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an Avatar'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: avatarUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(avatarUrls[index]),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(avatarUrls[index]),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedAvatar == null) return;

    try {
      // Update DB with selected avatar URL
      dynamic updated;
      try {
        updated = await supabase.from('pets').update({'photo_url': selectedAvatar}).eq('id', pet['id']).select().maybeSingle();
      } catch (_) {
        // maybeSingle() not available -> select() returns List
        final res = await supabase.from('pets').update({'photo_url': selectedAvatar}).eq('id', pet['id']).select();
        if (res == null || (res is List && res.isEmpty)) throw Exception('Update returned empty');
        updated = (res is List) ? res.first : res;
      }

      if (updated == null) throw Exception('Update failed');
      setState(() => pet = Map<String, dynamic>.from(updated as Map<String, dynamic>));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _editPet() async {
    // if you have a PetDialog in your project, replace the following with the dialog call:
    // final updated = await showDialog<bool>(context: context, builder: (_) => PetDialog(pet: pet));
    // if (updated == true) await _refreshFromDb();
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
                    onTap: _promptAddPhoto,
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