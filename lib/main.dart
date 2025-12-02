import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'screens/dashboard.dart';
import 'screens/petsPage.dart';
import 'screens/nearby.dart';
import 'screens/Articles.dart';
import 'screens/settings.dart';
import 'LoginForms/login.dart';
import 'services/SessionManager.dart';
import 'firebase_options.dart';

Future<String?> getFullname() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final response = await supabase
      .from('profiles')
      .select('fullname')
      .eq('id', user.id)
      .single();

  if (response.isEmpty) return null;

  return response['fullname'] as String?;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://xfmusoxrdhuzmaxffwyq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhmbXVzb3hyZGh1em1heGZmd3lxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzYyNzcsImV4cCI6MjA3MjY1MjI3N30.-VQ7z2fDpHnzBTgO1b9AhxzLwNRyO6fmzmoiM59a1Dk',
  );

  // Initialize notifications
  await NotificationService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionManager(),
      child: const PetPalApp(),
    ),
  );
}

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class PetPalApp extends StatelessWidget {
  const PetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'PetPal – Pet Care Organizer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.teal,
              unselectedItemColor: Colors.grey,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: Colors.teal,
              unselectedItemColor: Colors.grey,
            ),
          ),
          themeMode: mode,
          home: SignInScreen(), // 👈 Login first
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    PetsPage(),
    // HealthOverviewPage(), // moved out of bottom nav
    NearbyPage(),
    ArticlesPage(),
    SettingPage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pets"),
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            label: "Nearby",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_sharp),
            label: "Pet Care Tips",
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

// ---------------- Dashboard Page (Today) ----------------

// ---------------- Pets Page ----------------

// ---------------- Health Overview Page ----------------

// ---------------- Expenses Page ----------------

// ---------------- Settings Page ----------------

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
