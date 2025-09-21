import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  bool _darkMode = false;
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
