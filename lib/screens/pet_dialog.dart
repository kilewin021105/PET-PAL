import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetDialog extends StatefulWidget {
  final Map<String, dynamic>? pet;

  const PetDialog({super.key, this.pet});

  @override
  State<PetDialog> createState() => _PetDialogState();
}

class _PetDialogState extends State<PetDialog> {
  late final TextEditingController nameController;
  late final TextEditingController typeController;
  late final TextEditingController ageController;
  late final TextEditingController descriptionController;
  late final TextEditingController breedController;
  late final TextEditingController colorController;
  late final TextEditingController genderController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.pet?['name'] ?? '');
    typeController = TextEditingController(text: widget.pet?['type'] ?? '');
    ageController = TextEditingController(
      text: widget.pet?['age']?.toString() ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.pet?['description'] ?? '',
    );
    breedController = TextEditingController(text: widget.pet?['species'] ?? '');
    colorController = TextEditingController(text: widget.pet?['color'] ?? '');
    genderController = TextEditingController(text: widget.pet?['gender'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    breedController.dispose();
    colorController.dispose();
    genderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
      if (widget.pet == null) {
        // Add new pet
        await Supabase.instance.client.from('pets').insert({
          'user_id': user.id,
          'name': name,
          'type': type,
          'species': breed,
          'age': int.tryParse(age) ?? 0,
          'color': color,
          'gender': gender,
          'description': description,
        });
      } else {
        // Update existing pet
        await Supabase.instance.client
            .from('pets')
            .update({
              'name': name,
              'type': type,
              'species': breed,
              'age': int.tryParse(age) ?? 0,
              'color': color,
              'gender': gender,
              'description': description,
            })
            .eq('id', widget.pet!['id']);
      }
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pet == null ? "Add Pet" : "Edit Pet"),
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
              decoration: const InputDecoration(labelText: "Breed/Species"),
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
          child: Text(widget.pet == null ? "Add" : "Update"),
          onPressed: _submit,
        ),
      ],
    );
  }
}
