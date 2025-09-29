import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPetDialog extends StatefulWidget {
  const AddPetDialog({super.key});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _age = '';
  String? _selectedAnimal;
  String? _selectedSpecies;
  bool _isLoading = false;

  final List<String> _animals = ['Dog', 'Cat', 'Bird', 'Fish', 'Other'];
  final Map<String, List<String>> _species = {
    'Dog': ['Labrador', 'Poodle', 'Bulldog', 'Other'],
    'Cat': ['Siamese', 'Persian', 'Maine Coon', 'Other'],
    'Bird': ['Parrot', 'Canary', 'Finch', 'Other'],
    'Fish': ['Goldfish', 'Betta', 'Guppy', 'Other'],
    'Other': ['Other'],
  };

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedAnimal != null &&
        _selectedSpecies != null) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      final pet = {
        'name': _name,
        'age': int.tryParse(_age) ?? 0,
        'type': _selectedAnimal,
        'species': _selectedSpecies,
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      };
      try {
        await Supabase.instance.client.from('pets').insert(pet);
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add pet: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Pet'),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSaved: (value) => _name = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _age = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter an age' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Animal'),
                      initialValue: _selectedAnimal,
                      items: _animals
                          .map(
                            (animal) => DropdownMenuItem(
                              value: animal,
                              child: Text(animal),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAnimal = val;
                          _selectedSpecies = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select an animal' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Breed/Species',
                      ),
                      initialValue: _selectedSpecies,
                      items:
                          (_selectedAnimal != null
                                  ? _species[_selectedAnimal!]!
                                  : <String>[])
                              .map(
                                (sp) => DropdownMenuItem(
                                  value: sp,
                                  child: Text(sp),
                                ),
                              )
                              .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSpecies = val),
                      validator: (value) => value == null
                          ? 'Please select a breed/species'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
