import 'package:flutter/material.dart';

void main() {
  runApp(const PetPalApp());
}

class PetPalApp extends StatefulWidget {
  const PetPalApp({super.key});

  @override
  State<PetPalApp> createState() => _PetPalAppState();
}

class _PetPalAppState extends State<PetPalApp> {
  bool _darkMode = false;

  void toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPal 🐾 Pet Care Organizer',
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),

      // Switch depending on dark mode
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,

      // Pass toggle function to MainScreen (or Settings)
      home: MainScreen(darkMode: _darkMode, onToggleDarkMode: toggleDarkMode),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool darkMode;
  final Function(bool) onToggleDarkMode;

  const MainScreen({
    super.key,
    required this.darkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    //TodayPage(),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.today, "Today", 0),
              _buildNavItem(Icons.pets, "Pets", 1),
              _buildNavItem(Icons.calendar_month, "Schedule", 2),
              _buildNavItem(Icons.article, "Articles", 3),
              _buildNavItem(Icons.settings, "Settings", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: isSelected ? 1.3 : 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Icon(
                  icon,
                  color: isSelected ? Colors.teal : Colors.grey,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 14 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.teal : Colors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Today Page ----------------
/*class TodayPage extends StatelessWidget {
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
}*/

// ---------------- Pets Page ----------------
class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final List<Map<String, String>> _pets = [];

  void _addPet() {
    _showPetDialog();
  }

  void _editPet(int index) {
    _showPetDialog(editIndex: index);
  }

  void _showPetDialog({int? editIndex}) {
    String name = editIndex != null ? _pets[editIndex]['name']! : '';
    String type = editIndex != null ? _pets[editIndex]['type']! : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null ? "Add Pet" : "Edit Pet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Pet Name"),
              controller: TextEditingController(text: name),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Pet Type"),
              controller: TextEditingController(text: type),
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
            child: Text(editIndex == null ? "Add" : "Save"),
            onPressed: () {
              if (name.isNotEmpty && type.isNotEmpty) {
                setState(() {
                  if (editIndex == null) {
                    _pets.add({'name': name, 'type': type});
                  } else {
                    _pets[editIndex] = {'name': name, 'type': type};
                  }
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _viewPetDetails(Map<String, String> pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet['name'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, size: 50, color: Colors.teal),
            Text("Type: ${pet['type']}"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
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
                  onTap: () => _viewPetDetails(pet), // tap to view details
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editPet(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _pets.removeAt(index);
                          });
                        },
                      ),
                    ],
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
