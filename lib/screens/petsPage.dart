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
    String name = '';
    String type = '';
    String age = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Pet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Pet Name"),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Pet Type"),
              onChanged: (value) => type = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Pet Age"),
              keyboardType: TextInputType.number,
              onChanged: (value) => age = value,
            ),
          ],
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

              if (name.isNotEmpty && type.isNotEmpty && age.isNotEmpty) {
                await Supabase.instance.client.from('pets').insert({
                  'user_id': user.id,
                  'name': name,
                  'type': type,
                  'age': int.tryParse(age) ?? 0,
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
                return ListTile(
                  leading: const Icon(Icons.pets, color: Colors.teal),
                  title: Text(pet['name'] ?? ''),
                  subtitle: Text("${pet['type']} • Age: ${pet['age']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePet(pet['id']),
                  ),
                );
              },
            ),
    );
  }
}
