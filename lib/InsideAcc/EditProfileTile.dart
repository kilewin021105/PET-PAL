import 'package:flutter/material.dart';

class EditProfileTile extends StatelessWidget {
  const EditProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    final List<IconData> dogFaces = [
      Icons.pets,
      Icons.pets_outlined,
      Icons.pets_rounded,
    ];

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: dogFaces
            .map(
              (icon) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(icon, color: Colors.teal),
              ),
            )
            .toList(),
      ),
      title: const Text(
        "Edit Profile",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
      },
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int _selectedImageIndex = 0;

  // Replace these with your actual image assets (add to assets folder + pubspec.yaml)
  final List<String> dogImages = [
    'assets/dog1.png',
    'assets/dog2.png',
    'assets/dog3.png',
  ];

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  void _changeImage() {
    setState(() {
      _selectedImageIndex =
          (_selectedImageIndex + 1) % dogImages.length; // cycles images
    });
  }

  void _saveProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated ✅")));
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
                    backgroundImage: AssetImage(dogImages[_selectedImageIndex]),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _changeImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.swap_horiz,
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
