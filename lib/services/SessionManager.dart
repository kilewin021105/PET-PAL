import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager extends ChangeNotifier {
  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    _firstName = null;
    _lastName = null;
    notifyListeners();
  }

  final supabase = Supabase.instance.client;

  User? _user;
  String? _firstName;
  String? _lastName;

  User? get user => _user;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get fullname => (_firstName != null && _lastName != null)
      ? '$_firstName $_lastName'
      : null;

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
        _firstName = null;
        _lastName = null;
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
        .select('first_name, last_name')
        .eq('id', _user!.id)
        .maybeSingle();

    _firstName = response?['first_name'] as String?;
    _lastName = response?['last_name'] as String?;
    notifyListeners();
  }
}
