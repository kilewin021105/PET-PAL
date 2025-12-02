import 'package:flutter_application_1/InsideAcc/HelpPage.dart';

import '../InsideAcc/EditProfileTile.dart';
import 'add_pet_dialog.dart';
import 'package:flutter/material.dart';
import '../services/SessionManager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' show MainScreen;
import '../LoginForms/login.dart';
import '../InsideAcc/pet_profile_page.dart';
import '../models/reminder.dart';
import '../services/reminder_fetch_service.dart';
import '../services/reminder_count_service.dart';
import 'add_reminder_dialog.dart';

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
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pets = [];
  int _reminderCount = 0;
  late Future<List<Reminder>> _remindersFuture;

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

  Future<void> _fetchReminderCount() async {
    try {
      final count = await getRemindersCount();
      setState(() {
        _reminderCount = count;
      });
    } catch (e) {
      // Handle error silently or log it
    }
  }

  void _refreshReminders() {
    setState(() {
      _remindersFuture = fetchReminders();
      _fetchReminderCount();
    });
  }

  String _getDueDateText(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      final daysDifference = reminderDate.difference(today).inDays;
      if (daysDifference > 0 && daysDifference <= 7) {
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return weekdays[reminderDate.weekday - 1];
      } else {
        return '${reminderDate.month}/${reminderDate.day}/${reminderDate.year}';
      }
    }
  }

  Widget _buildReminderCard(Reminder reminder, BuildContext context) {
    Color statusColor;
    String statusText;
    switch (reminder.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'missed':
        statusColor = Colors.red;
        statusText = 'Missed';
        break;
      case 'past':
        statusColor = Colors.purple;
        statusText = 'Past';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    final now = DateTime.now();
    final isToday = reminder.dateTime.toLocal().year == now.year &&
                    reminder.dateTime.toLocal().month == now.month &&
                    reminder.dateTime.toLocal().day == now.day;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reminder.description,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Due: ${_getDueDateText(reminder.dateTime)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (reminder.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client
                          .from('remindersbadge')
                          .update({'status': 'completed'})
                          .eq('id', reminder.id)
                          .eq('user_id', userId);
                      _refreshReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder marked as completed')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating reminder: $e')),
                      );
                    }
                  },
                  child: const Text('Mark Completed', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client
                          .from('remindersbadge')
                          .update({'status': 'missed'})
                          .eq('id', reminder.id)
                          .eq('user_id', userId);
                      _refreshReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder marked as missed')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating reminder: $e')),
                      );
                    }
                  },
                  child: const Text('Mark Missed', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          if (reminder.status == 'missed' || reminder.status == 'past') ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final DateTime now = DateTime.now();
                final DateTime initialDate = reminder.dateTime.isBefore(now) ? now : reminder.dateTime;
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(reminder.dateTime),
                  );
                  if (pickedTime != null) {
                    final DateTime newDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client
                          .from('remindersbadge')
                          .update({
                            'status': 'pending',
                            'date_time': newDateTime.toIso8601String()
                          })
                          .eq('id', reminder.id)
                          .eq('user_id', userId);
                      _refreshReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder rescheduled successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error rescheduling reminder: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Reschedule', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ],
      ),
    );
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
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: 'Reminders',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FutureBuilder<List<Reminder>>(
                      future: _remindersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return SizedBox(
                            height: 200,
                            child: Center(child: Text('Error: ${snapshot.error}')),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: Text('No reminders found.')),
                          );
                        }

                        final reminders = snapshot.data!;
                        final pending = reminders.where((r) => r.status == 'pending').toList();
                        final completed = reminders.where((r) => r.status == 'completed').toList();
                        final missed = reminders.where((r) => r.status == 'missed').toList();
                        final past = reminders.where((r) => r.status == 'past').toList();

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Reminders',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final added = await showDialog(
                                        context: context,
                                        builder: (context) => const AddReminderDialog(),
                                      );
                                      if (added != null) {
                                        _refreshReminders();
                                      }
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Reminder'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Overall Record Card
                              Container(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Reminder Record',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Text('${pending.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                                            const Text('Pending'),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text('${completed.length + missed.length + past.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                                            const Text('Past'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Ongoing Reminders
                                      if (pending.isNotEmpty) ...[
                                        const Text('Ongoing Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        ...pending.map((reminder) => _buildReminderCard(reminder, context)),
                                        const SizedBox(height: 24),
                                      ],
                                      // Past Reminders
                                      if ((completed + missed + past).isNotEmpty) ...[
                                        const Text('Past Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        ...(completed + missed + past).map((reminder) => _buildReminderCard(reminder, context)),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              if (_reminderCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_reminderCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
                        radius: 30,
                        backgroundColor: hasAvatar ? null : Colors.teal[100],
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
                      radius: 30,
                      backgroundColor: hasAvatar ? null : Colors.teal,
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


