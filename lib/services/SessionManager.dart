import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  User? _user;
  String? _fullname;

  User? get user => _user;
  String? get fullname => _fullname;

  SessionManager() {
    // Watch for auth changes (login, logout, refresh)
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        _user = session?.user;
        _fetchProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _fullname = null;
      }
      notifyListeners();
    });

    // Load current user if already logged in
    _user = supabase.auth.currentUser;
    if (_user != null) {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    if (_user == null) return;
    final response = await supabase
        .from('profiles')
        .select('fullname')
        .eq('id', _user!.id)
        .maybeSingle();

    _fullname = response?['fullname'] as String?;
    notifyListeners();
  }
}
