import 'package:flutter/material.dart';
import 'package:flutter_application_1/LoginForms/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/SessionManager.dart';
import 'package:flutter_application_1/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://xfmusoxrdhuzmaxffwyq.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhmbXVzb3hyZGh1em1heGZmd3lxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzYyNzcsImV4cCI6MjA3MjY1MjI3N30.-VQ7z2fDpHnzBTgO1b9AhxzLwNRyO6fmzmoiM59a1Dk",
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<SessionManager>(
        builder: (context, session, _) {
          if (session.user == null) {
            return const SignInScreen(); // your login page
          } else {
            return const MainScreen(); // your dashboard
          }
        },
      ),
    );
  }
}
