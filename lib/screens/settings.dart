import 'package:flutter/material.dart';

import '../main.dart'; // Import themeNotifier

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  bool _locationSharing = false;
  bool _cloudBackup = true;
  String _notificationSound = "Default";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PetPal Settings")),
      body: ListView(
        children: [
          // 🐾 Pet Profile Section
          _buildSectionHeader("Pet Profile"),
          ListTile(
            leading: Icon(
              Icons.pets,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.teal,
            ),
            title: const Text("My Pets"),
            subtitle: const Text("Pets settings"),
            onTap: () {
              // Navigate to pet profile page
            },
          ),

          const Divider(),

          // 🎨 App Preferences
          _buildSectionHeader("App Preferences"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeNotifier.value == ThemeMode.dark,
            onChanged: (value) {
              setState(() {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              });
            },
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
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.teal,
            ),
            onTap: () => _showNotificationSoundDialog(),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // Call your logout logic here
              }
            },
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

  // 🔹 Accent Color Dialog

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
