import 'package:flutter/material.dart';

void main() {
  runApp(const PetPalApp());
}

class PetPalApp extends StatelessWidget {
  const PetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPal – Pet Care Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    TodayPage(),
    PetsPage(),
    SchedulePage(),
    ExpensesPage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pets"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Expenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

// ---------------- Today Page ----------------
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Overview")),
      body: const Center(
        child: Text(
          "Your pet care tasks for today.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// ---------------- Pets Page ----------------
class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final List<Map<String, String>> _pets = [];

  void _addPet() {
    String name = '';
    String type = '';

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
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (name.isNotEmpty && type.isNotEmpty) {
                setState(() {
                  _pets.add({'name': name, 'type': type});
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
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
                  subtitle: Text(pet['type'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _pets.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ---------------- Schedule Page ----------------
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      body: const Center(
        child: Text(
          "Schedule pet care activities.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// ---------------- Expenses Page ----------------
class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: const Center(
        child: Text(
          "Track your pet expenses here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// ---------------- Settings Page ----------------
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(
        child: Text(
          "App settings will be available here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
