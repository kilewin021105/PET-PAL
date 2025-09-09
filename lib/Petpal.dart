import 'package:flutter/material.dart';
//import 'package:flutter_application_1/screens/Articles.dart';

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
    ArticlesPage(),
    SettingPage(),
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
            label: "Articles",
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
class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Articles")),
      body: const Center(
        child: Text("this are the articles", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ---------------- Settings Page ----------------
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  bool _darkMode = false;
  bool _feedingReminders = true;
  bool _vetReminders = true;
  bool _walkReminders = false;
  bool _locationSharing = false;
  bool _cloudBackup = true;
  String _language = "English";
  String _notificationSound = "Default";
  String _accentColor = "Blue";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PetPal Settings")),
      body: ListView(
        children: [
          // 🐾 Pet Profile Section
          _buildSectionHeader("Pet Profile"),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text("My Pets"),
            subtitle: const Text("View and edit your pets’ info"),
            onTap: () {
              // Navigate to pet profile page
            },
          ),

          const Divider(),

          // ⏰ Reminders
          _buildSectionHeader("Reminders"),
          SwitchListTile(
            title: const Text("Feeding Reminders"),
            subtitle: const Text("Get notified when it’s meal time"),
            value: _feedingReminders,
            onChanged: (value) => setState(() => _feedingReminders = value),
          ),
          SwitchListTile(
            title: const Text("Vet Appointment Reminders"),
            subtitle: const Text("Stay updated on vet visits"),
            value: _vetReminders,
            onChanged: (value) => setState(() => _vetReminders = value),
          ),
          SwitchListTile(
            title: const Text("Walk Reminders"),
            subtitle: const Text("Don’t forget daily walks"),
            value: _walkReminders,
            onChanged: (value) => setState(() => _walkReminders = value),
          ),

          const Divider(),

          // 🎨 App Preferences
          _buildSectionHeader("App Preferences"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
          ),
          ListTile(
            title: const Text("Accent Color"),
            subtitle: Text(_accentColor),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAccentColorDialog(),
          ),
          ListTile(
            title: const Text("Language"),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(),
          ),

          const Divider(),

          // 📍 Privacy & Security
          _buildSectionHeader("Privacy & Security"),
          SwitchListTile(
            title: const Text("Location Sharing"),
            subtitle: const Text("Enable GPS for lost pet alerts"),
            value: _locationSharing,
            onChanged: (value) => setState(() => _locationSharing = value),
          ),

          const Divider(),

          // ☁️ Backup & Notifications
          _buildSectionHeader("Backup & Notifications"),
          SwitchListTile(
            title: const Text("Cloud Backup"),
            subtitle: const Text("Keep pet data synced online"),
            value: _cloudBackup,
            onChanged: (value) => setState(() => _cloudBackup = value),
          ),
          ListTile(
            title: const Text("Notification Sound"),
            subtitle: Text(_notificationSound),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showNotificationSoundDialog(),
          ),

          const Divider(),

          // 👤 Account
          _buildSectionHeader("Account"),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            subtitle: const Text("Manage your PetPal account"),
            onTap: () {
              // Navigate to account page
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {
              // Navigate to password reset page
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper: Section Headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 🔹 Language Dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption("English", _language, (val) {
              setState(() => _language = val);
              Navigator.pop(context);
            }),
            _buildRadioOption("Tagalog", _language, (val) {
              setState(() => _language = val);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  // 🔹 Accent Color Dialog
  void _showAccentColorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Accent Color"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption("Blue", _accentColor, (val) {
              setState(() => _accentColor = val);
              Navigator.pop(context);
            }),
            _buildRadioOption("Green", _accentColor, (val) {
              setState(() => _accentColor = val);
              Navigator.pop(context);
            }),
            _buildRadioOption("Orange", _accentColor, (val) {
              setState(() => _accentColor = val);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  // 🔹 Notification Sound Dialog
  void _showNotificationSoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Notification Sound"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption("Default", _notificationSound, (val) {
              setState(() => _notificationSound = val);
              Navigator.pop(context);
            }),
            _buildRadioOption("Chime", _notificationSound, (val) {
              setState(() => _notificationSound = val);
              Navigator.pop(context);
            }),
            _buildRadioOption("Bark", _notificationSound, (val) {
              setState(() => _notificationSound = val);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  // 🔹 Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout of PetPal?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Logout"),
            onPressed: () {
              Navigator.pop(context);
              // TODO: add logout logic
            },
          ),
        ],
      ),
    );
  }

  // 🔹 Helper: Radio Option
  Widget _buildRadioOption(
    String value,
    String group,
    Function(String) onSelect,
  ) {
    return RadioListTile(
      title: Text(value),
      value: value,
      groupValue: group,
      onChanged: (val) => onSelect(val as String),
    );
  }
}
