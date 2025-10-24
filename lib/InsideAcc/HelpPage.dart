import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package in pubspec.yaml

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // Function to open email app for contact support
  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      query: 'subject=App Support Request&body=Hi, I need help with...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Example FAQs
          ExpansionTile(
            title: const Text("How do I edit my profile?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Go to 'Edit Profile' from your account page, change your info, then tap Save Changes.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("How can I reset my password?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "From the login screen, tap 'Forgot Password' and follow the instructions to reset it.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("How do I delete my account?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Go to Account Settings and select 'Delete Account'. You’ll need to confirm before deletion.",
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Need more help?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "If you didn’t find what you’re looking for, contact our support team and we’ll get back to you as soon as possible.",
          ),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: _contactSupport,
              icon: const Icon(Icons.email_outlined),
              label: const Text("Contact Support"),
            ),
          ),
        ],
      ),
    );
  }
}
