import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  List<Map<String, dynamic>> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('pets')
        .select()
        .eq('user_id', user.id);

    setState(() {
      _pets = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addPet() async {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final ageController = TextEditingController();
    final descriptionController = TextEditingController();
    final breedController = TextEditingController();
    final colorController = TextEditingController();
    final genderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Pet"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Pet Name"),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Pet Type"),
              ),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: "Breed"),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Pet Age"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: "Color"),
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () async {
              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              final name = nameController.text.trim();
              final type = typeController.text.trim();
              final breed = breedController.text.trim();
              final age = ageController.text.trim();
              final color = colorController.text.trim();
              final gender = genderController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isNotEmpty && type.isNotEmpty && age.isNotEmpty) {
                await Supabase.instance.client.from('pets').insert({
                  'user_id': user.id,
                  'name': name,
                  'type': type,
                  'breed': breed,
                  'age': int.tryParse(age) ?? 0,
                  'color': color,
                  'gender': gender,
                  'description': description,
                });
                Navigator.pop(context);
                _loadPets(); // refresh pets after insert
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editPet(Map<String, dynamic> pet) async {
    final nameController = TextEditingController(text: pet['name'] ?? '');
    final typeController = TextEditingController(text: pet['type'] ?? '');
    final ageController = TextEditingController(text: pet['age']?.toString() ?? '');
    final descriptionController = TextEditingController(text: pet['description'] ?? '');
    final breedController = TextEditingController(text: pet['breed'] ?? '');
    final colorController = TextEditingController(text: pet['color'] ?? '');
    final genderController = TextEditingController(text: pet['gender'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Pet"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Pet Name"),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Pet Type"),
              ),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: "Breed"),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Pet Age"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: "Color"),
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () async {
              final name = nameController.text.trim();
              final type = typeController.text.trim();
              final breed = breedController.text.trim();
              final age = ageController.text.trim();
              final color = colorController.text.trim();
              final gender = genderController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isNotEmpty && type.isNotEmpty && age.isNotEmpty) {
                await Supabase.instance.client
                    .from('pets')
                    .update({
                      'name': name,
                      'type': type,
                      'breed': breed,
                      'age': int.tryParse(age) ?? 0,
                      'color': color,
                      'gender': gender,
                      'description': description,
                    })
                    .eq('id', pet['id']);
                Navigator.pop(context);
                _loadPets(); // refresh pets after update
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deletePet(String id) async {
    await Supabase.instance.client.from('pets').delete().eq('id', id);
    _loadPets(); // refresh after delete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addPet)],
      ),
      body: _pets.isEmpty
          ? const Center(child: Text("No pets added yet."))
          : ListView.builder(
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.pets, color: Colors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pet['name'] ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editPet(pet),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePet(pet['id']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${pet['type'] ?? ''} • ${pet['breed'] ?? ''} • Age: ${pet['age'] ?? ''} • ${pet['color'] ?? ''} • ${pet['gender'] ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (pet['description'] != null && pet['description'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Description: ${pet['description']}",
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
