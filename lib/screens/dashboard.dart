import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/SessionManager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Stub pages (replace with your own implementations)
class PetProfilePage extends StatelessWidget {
  final Map<String, dynamic> pet;
  const PetProfilePage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${pet['name']}'s Profile")),
      body: Center(
        child: Text(
          "Type: ${pet['type']}\nAge: ${pet['age']}",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    final response = await supabase.from('pets').select();
    setState(() {
      pets = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionManager>(context);
    final fullname = session.fullname ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            //Remnder icon button
            icon: const Icon(Icons.notifications_none, color: Colors.teal),
            tooltip: "Reminders",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersPage()),
              );
            },
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
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
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.teal[100],
                    child: const Icon(
                      Icons.person,
                      color: Colors.teal,
                      size: 32,
                    ),
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

            // Pet cards
            pets.isEmpty
                ? const Center(child: Text("No pets found. Add some pets!"))
                : Column(
                    children: pets.map((pet) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
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
                              child: const Icon(
                                Icons.pets,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${pet['type']} • ${pet['age']} years old",
                                    style: const TextStyle(
                                      color: Colors.grey,
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
                                    builder: (context) =>
                                        PetProfilePage(pet: pet),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ManagePetPage(pet: pet),
                                  ),
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

            // Upcoming Reminders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Reminders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Reminder tapped!')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reminder Cards
            const ReminderCard(
              icon: Icons.favorite_border,
              title: 'Vet Check-up',
              subtitle: 'Tomorrow, 2:00 PM',
              badgeText: 'Due Soon',
              badgeColor: Colors.teal,
            ),
            const SizedBox(height: 12),
            const ReminderCard(
              icon: Icons.science_outlined,
              title: 'Medication',
              subtitle: 'Daily at 8:00 AM',
              badgeText: 'Daily',
              badgeColor: Colors.green,
            ),
            const SizedBox(height: 24),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Profile Section
          Center(
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  "John Doe", // Replace with session.fullname if needed
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "johndoe@email.com", // Replace with session.email
                  style: TextStyle(color: Colors.grey),
                ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit Profile tapped")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.teal),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Change Password tapped")),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
              color: Colors.teal,
            ),
            title: const Text("Notification Settings"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification Settings tapped")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () async {
              // 1. Log out from Supabase
              await Supabase.instance.client.auth.signOut();

              // 2. Show confirmation
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Logged out")));

              // 3. Navigate back to login page
              Navigator.pushReplacementNamed(context, '/login');
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
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
