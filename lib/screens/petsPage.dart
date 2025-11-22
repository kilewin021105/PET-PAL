import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pet_dialog.dart';

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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PetDialog(),
    );
    if (result == true) {
      _loadPets();
    }
  }

  Future<void> _editPet(Map<String, dynamic> pet) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PetDialog(pet: pet),
    );
    if (result == true) {
      _loadPets();
    }
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (pet['photo_url'] != null && (pet['photo_url'] as String).isNotEmpty)
                                      ? NetworkImage(pet['photo_url'])
                                      : null,
                                  child: (pet['photo_url'] == null || (pet['photo_url'] as String).isEmpty)
                                      ? const Icon(
                                          Icons.pets,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pet['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                          "${pet['type'] ?? ''} • ${pet['species'] ?? ''} • Age: ${pet['age'] ?? ''} • ${pet['color'] ?? ''} • ${pet['gender'] ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (pet['description'] != null &&
                            pet['description'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Description: ${pet['description']}",
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
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
