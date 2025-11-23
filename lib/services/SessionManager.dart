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
    _avatarUrl = null;
    notifyListeners(); // Notify UI of changes
  }

  // Supabase client instance
  final supabase = Supabase.instance.client;

  // Private user and profile fields
  User? _user;
  String? _firstName;
  String? _lastName;
  String? _avatarUrl;

  // Public getters for user and profile info
  User? get user => _user;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get avatarUrl => _avatarUrl;
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
        .select('first_name, last_name, avatar_url, photo_url, image_url')
        .eq('id', _user!.id)
        .maybeSingle();

    _firstName = response?['first_name'] as String?;
    _lastName = response?['last_name'] as String?;
    final dynamic a = response?['avatar_url'] ?? response?['photo_url'] ?? response?['image_url'];
    _avatarUrl = (a is String && a.isNotEmpty) ? a : null;
    notifyListeners(); // Update UI with new profile info
  }

  // Update avatar in Supabase and notify listeners
  Future<void> setAvatarUrl(String? url) async {
    _avatarUrl = url;
    notifyListeners();
    if (_user == null) return;
    try {
      await supabase.from('profiles').upsert({'id': _user!.id, 'avatar_url': url});
    } catch (_) {}
  }
}
