import 'package:flutter/material.dart';
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

  int _selectedIcon = Icons.person.codePoint;

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
          .single();

      setState(() {
        nameController.text = response['name'] ?? '';
        emailController.text = response['email'] ?? '';
        _selectedIcon = response['icon_code'] ?? Icons.person.codePoint;
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
        'icon_code': _selectedIcon,
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
  // ICON PICKER DIALOG
  // ----------------------------------
  Future<void> _pickIcon() async {
    final icons = [
      Icons.person,
      Icons.pets,
      Icons.favorite,
      Icons.star,
      Icons.home,
      Icons.face,
      Icons.directions_walk,
      Icons.directions_run,
      Icons.gps_fixed,
      Icons.catching_pokemon,
      Icons.shield,
      Icons.lock,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose an Icon"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: icons.map((icon) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon.codePoint;
                  });
                  Navigator.pop(context);
                },
                child: Icon(icon, size: 32),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ----------------------------------
  // UI
  // ----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Avatar Icon
            Center(
              child: GestureDetector(
                onTap: _pickIcon,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(
                    IconData(_selectedIcon, fontFamily: 'MaterialIcons'),
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
