import 'package:flutter_application_1/InsideAcc/HelpPage.dart';

import '../InsideAcc/EditProfileTile.dart';
import 'add_pet_dialog.dart';
import '../services/reminder_count_service.dart' as count_service;
import 'package:flutter/material.dart';
import '../services/SessionManager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' show MainScreen;
import '../LoginForms/login.dart';
import 'add_reminder_dialog.dart';
import '../models/reminder.dart';
import '../services/reminder_fetch_service.dart';
import '../InsideAcc/pet_profile_page.dart';

// PetProfilePage class removed from this file.
// Use PetProfileScreen in lib/InsideAcc/pet_profile_page.dart:
// Navigator.push(context, MaterialPageRoute(builder: (_) => PetProfileScreen(pet: Map<String, dynamic>.from(pet))));

class ManagePetPage extends StatelessWidget {
  final Map<String, dynamic> pet;
  const ManagePetPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage ${pet['name']}")),
      body: const Center(child: Text("Here you can edit or delete the pet.")),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _reminderCount = 0;

  Future<void> _fetchReminderCount() async {
    final count = await count_service.getRemindersCount();
    if (mounted) setState(() => _reminderCount = count);
  }

  late Future<List<Reminder>> _remindersFuture;
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pets = [];

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _remindersFuture = fetchReminders();
    _fetchReminderCount();
  }

  Future<void> _fetchPets() async {
    try {
      // Modern supabase-dart returns rows directly from select() (no .execute())
      final res = await supabase
          .from('pets')
          .select()
          .order('id', ascending: true);
      final data = (res as List<dynamic>?) ?? <dynamic>[];
      setState(() {
        pets = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading pets: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionManager>(context);
    final fullname = session.fullname ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        // Use theme colors for AppBar
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color.fromARGB(255, 218, 226, 226),
                ),
                tooltip: "Reminders",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    builder: (context) => Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.7,
                        minChildSize: 0.4,
                        maxChildSize: 0.95,
                        builder: (context, scrollController) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        'PetPal Reminders',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final added = await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const AddReminderDialog(),
                                        );
                                        if (added == true) {
                                          setState(() {
                                            _remindersFuture = fetchReminders();
                                          });
                                          _fetchReminderCount();
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Reminder'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder<List<Reminder>>(
                                  future: _remindersFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text('No reminders found.'),
                                      );
                                    }
                                    final reminders = snapshot.data!;
                                    return ListView.separated(
                                      controller: scrollController,
                                      itemCount: reminders.length,
                                      separatorBuilder: (context, i) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, i) {
                                        final r = reminders[i];
                                        return ListTile(
                                          title: Text(r.title),
                                          subtitle: Text(r.description),
                                          trailing: Text(
                                            '${r.dateTime.month}/${r.dateTime.day}/${r.dateTime.year} ${r.dateTime.hour.toString().padLeft(2, '0')}:${r.dateTime.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                    }
                  ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              if (_reminderCount > 0)
                Positioned(
                  right: 10,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_reminderCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
                  ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting (make avatar clickable too if you want)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      final session = Provider.of<SessionManager>(context);
                      final url = session.avatarUrl;
                      final hasAvatar = url != null && url.isNotEmpty;
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal[100],
                        backgroundImage: hasAvatar ? NetworkImage(url) : null,
                        child: hasAvatar
                            ? null
                            : const Icon(
                                Icons.person,
                                color: Colors.teal,
                                size: 32,
                              ),
                      );
                    }
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $fullname",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Welcome back to PetPal',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final added = await showDialog(
                      context: context,
                      builder: (context) => const AddPetDialog(),
                    );
                    if (added == true) {
                      _fetchPets();
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pet cards
            pets.isEmpty
                ? const Center(child: Text("No pets found. Add some pets!"))
                : Column(
                    children: pets.map((pet) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: (pet['photo_url'] != null && (pet['photo_url'] as String).isNotEmpty)
                                  ? NetworkImage(pet['photo_url'])
                                  : null,
                              child: (pet['photo_url'] == null || (pet['photo_url'] as String).isEmpty)
                                  ? const Icon(
                                      Icons.pets,
                                      color: Colors.grey,
                                      size: 32,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${pet['type']} • ${pet['age']} years old",
                                    style: TextStyle(
                                      fontWeight:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PetProfileScreen(
                                      pet: Map<String, dynamic>.from(pet),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('View Profile'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MainScreen(initialIndex: 1),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text('Manage'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionManager>(context);
    final fullname = session.fullname ?? "User";
    final email = session.user?.email ?? "No Email";
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Consumer<SessionManager>(
                  builder: (context, session, _) {
                    final url = session.avatarUrl;
                    final hasAvatar = url != null && url.isNotEmpty;
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal,
                      backgroundImage: hasAvatar ? NetworkImage(url) : null,
                      child: hasAvatar
                          ? null
                          : const Icon(Icons.person, size: 40, color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  fullname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Divider(),

          // Account Options
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.teal),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.teal),
            title: const Text("Help & Support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              await session.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

//Mao ni ang Reminders Page
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PetPal Reminders"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ReminderCard(
            icon: Icons.favorite_border,
            title: 'Vet Check-up',
            subtitle: 'Tomorrow, 2:00 PM',
            badgeText: 'Due Soon',
            badgeColor: Colors.teal,
          ),
          SizedBox(height: 12),
          ReminderCard(
            icon: Icons.science_outlined,
            title: 'Medication',
            subtitle: 'Daily at 8:00 AM',
            badgeText: 'Daily',
            badgeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;

  const ReminderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey,
                    fontWeight: isDark ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
