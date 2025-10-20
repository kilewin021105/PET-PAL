// Handles user authentication and profile state
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager extends ChangeNotifier {
  // Signs out the user and clears profile info
  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    _firstName = null;
    _lastName = null;
    notifyListeners(); // Notify UI of changes
  }

  // Supabase client instance
  final supabase = Supabase.instance.client;

  // Private user and profile fields
  User? _user;
  String? _firstName;
  String? _lastName;

  // Public getters for user and profile info
  User? get user => _user;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get fullname => (_firstName != null && _lastName != null)
      ? '$_firstName $_lastName'
      : null;

  // Constructor: sets up auth state listener and loads current user
  SessionManager() {
    // Listen for authentication state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        _user = session?.user; // Set user on sign in
        _fetchProfile(); // Fetch profile info
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _firstName = null;
        _lastName = null;
      }
      notifyListeners(); // Update UI
    });

    // Load current user if already logged in
    _user = supabase.auth.currentUser;
    if (_user != null) {
      _fetchProfile();
    }
  }

  // Fetches profile info (first/last name) from Supabase
  Future<void> _fetchProfile() async {
    if (_user == null) return;
    final response = await supabase
        .from('profiles')
        .select('first_name, last_name')
        .eq('id', _user!.id)
        .maybeSingle();

    _firstName = response?['first_name'] as String?;
    _lastName = response?['last_name'] as String?;
    notifyListeners(); // Update UI with new profile info
  }
}
