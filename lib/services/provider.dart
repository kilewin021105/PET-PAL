// Main entry point for the Flutter app
import 'package:flutter/material.dart';
// Import the login screen
import 'package:flutter_application_1/LoginForms/login.dart';
// Provider package for state management
import 'package:provider/provider.dart';
// SessionManager handles user authentication state
import 'package:flutter_application_1/services/SessionManager.dart';
// MainScreen is the dashboard/home after login
import 'package:flutter_application_1/main.dart';
// Supabase for backend/database/auth
import 'package:supabase_flutter/supabase_flutter.dart';

// Initializes Flutter bindings and Supabase, then runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures widgets are ready before async code
  await Supabase.initialize(
    url: "https://xfmusoxrdhuzmaxffwyq.supabase.co", // Supabase project URL
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhmbXVzb3hyZGh1em1heGZmd3lxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzYyNzcsImV4cCI6MjA3MjY1MjI3N30.-VQ7z2fDpHnzBTgO1b9AhxzLwNRyO6fmzmoiM59a1Dk", // Supabase anon key
  );

  // Provide SessionManager to the widget tree for auth state
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionManager(), // Creates the session manager
      child: const MyApp(), // Main app widget
    ),
  );
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      // Use Consumer to listen for auth state changes
      home: Consumer<SessionManager>(
        builder: (context, session, _) {
          // If not logged in, show login screen
          if (session.user == null) {
            return const SignInScreen(); // Login page
          } else {
            return const MainScreen(); // Dashboard/home
          }
        },
      ),
    );
  }
}
