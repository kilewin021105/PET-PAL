import 'package:flutter/material.dart';
import 'package:flutter_application_1/LoginForms/login.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Hive.initFlutter();
   await Hive.openBox('userBox');
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
      home: SignInScreen(),
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
    DashboardPage(),
    PetsPage(),
    HealthOverviewPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: "Health"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Expenses"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

// ---------------- Dashboard Page (Today) ----------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal[100],
                  child: const Text(
                    'JD',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hello, John!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Welcome back to PetPal',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pet Card
            Container(
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
                    child: const Icon(Icons.pets, color: Colors.grey, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Buddy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Golden Retriever • 3 years old',
                          style: TextStyle(
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
                        MaterialPageRoute(builder: (context) => const PetProfilePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('View Profile'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManagePetPage()),
                      );
                    },
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Upcoming Reminders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Reminders',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Reminder tapped!')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reminder Cards
            ReminderCard(
              icon: Icons.favorite_border,
              title: 'Vet Check-up',
              subtitle: 'Tomorrow, 2:00 PM',
              badgeText: 'Due Soon',
              badgeColor: Colors.teal,
            ),
            const SizedBox(height: 12),
            ReminderCard(
              icon: Icons.science_outlined,
              title: 'Medication',
              subtitle: 'Daily at 8:00 AM',
              badgeText: 'Daily',
              badgeColor: Colors.green,
            ),
            const SizedBox(height: 12),

            // View All Reminders Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllRemindersPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDEDED),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'View All Reminders',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

// ---------------- Pets Page ----------------
class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  List<Map<String, String>> _pets = [];

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

// ---------------- Health Overview Page ----------------
class HealthOverviewPage extends StatelessWidget {
  const HealthOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example pet card (can be expanded as needed)
            Container(
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
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.pets, color: Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Max',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Golden Retriever',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'All good',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Next: Vaccination in 2 weeks',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Upcoming Health Events Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Health Events',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Medication Reminder
            HealthEventCard(
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: 'Medication Reminder',
              titleColor: Colors.red,
              dateLabel: 'Today',
              dateLabelColor: Colors.red,
              description: 'Give Luna her heart medication',
              tags: [
                HealthTag(label: 'Luna', color: Colors.blueGrey),
                HealthTag(label: 'Due now', color: Colors.red, bgColor: Colors.redAccent.withOpacity(0.15)),
              ],
            ),
            const SizedBox(height: 12),

            // Vet Appointment
            HealthEventCard(
              icon: Icons.calendar_today,
              iconColor: Colors.blue,
              title: 'Vet Appointment',
              titleColor: Colors.blue,
              dateLabel: 'Tomorrow',
              dateLabelColor: Colors.blue,
              description: 'Annual checkup for Charlie',
              tags: [
                HealthTag(label: 'Charlie', color: Colors.blueGrey),
                HealthTag(label: '2:00 PM', color: Colors.blue, bgColor: Colors.blue.withOpacity(0.15)),
                HealthTag(label: 'Dr. Smith', color: Colors.deepPurple, bgColor: Colors.deepPurple.withOpacity(0.15)),
              ],
            ),
            const SizedBox(height: 12),

            // Vaccination
            HealthEventCard(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Vaccination',
              titleColor: Colors.green,
              dateLabel: 'Sep 15, 2025',
              dateLabelColor: Colors.grey,
              description: 'Annual rabies vaccination for Max',
              tags: [
                HealthTag(label: 'Max', color: Colors.blueGrey),
                HealthTag(label: 'Rabies', color: Colors.green, bgColor: Colors.green.withOpacity(0.15)),
              ],
            ),
            const SizedBox(height: 12),

            // Vaccination Overdue
            HealthEventCard(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title: 'Vaccination Overdue',
              titleColor: Colors.orange,
              dateLabel: '3 days ago',
              dateLabelColor: Colors.orange,
              description: 'FVRCP vaccination for Luna',
              tags: [
                HealthTag(label: 'Luna', color: Colors.blueGrey),
                HealthTag(label: 'FVRCP', color: Colors.orange, bgColor: Colors.orange.withOpacity(0.15)),
                HealthTag(label: 'Overdue', color: Colors.orange, bgColor: Colors.orange.withOpacity(0.15)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class HealthEventCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String dateLabel;
  final Color dateLabelColor;
  final String description;
  final List<HealthTag> tags;

  const HealthEventCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.dateLabel,
    required this.dateLabelColor,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: titleColor,
                  ),
                ),
              ),
              Text(
                dateLabel,
                style: TextStyle(
                  color: dateLabelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags,
          ),
        ],
      ),
    );
  }
}

class HealthTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;

  const HealthTag({
    super.key,
    required this.label,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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

// ---------------- Dummy Pages for Navigation ----------------
class PetProfilePage extends StatelessWidget {
  const PetProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Profile')),
      body: const Center(child: Text('Pet Profile Page')),
    );
  }
}

class ManagePetPage extends StatelessWidget {
  const ManagePetPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Pet')),
      body: const Center(child: Text('Manage Pet Page')),
    );
  }
}

class AllRemindersPage extends StatelessWidget {
  const AllRemindersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Reminders')),
      body: const Center(child: Text('All Reminders Page')),
    );
  }
}
