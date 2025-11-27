// Handles user authentication and profile state
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends ChangeNotifier {
  // Signs out the user and clears profile info
  Future<void> signOut() async {
    // Save current profile data to SharedPreferences before clearing
    await _saveProfileToPrefs();
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
  String? _email;

  // Public getters for user and profile info
  User? get user => _user;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get avatarUrl => _avatarUrl;
  String? get email => _email ?? _user?.email;
  String? get fullname {
    if (_firstName != null && _lastName != null) return '$_firstName $_lastName';
    if (_firstName != null && _firstName!.isNotEmpty) return _firstName;
    if (_lastName != null && _lastName!.isNotEmpty) return _lastName;
    return null;
  }

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
        _avatarUrl = null;
        _email = null; // ensure email state is cleared on sign-out
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

    try {
      // Attempt to fetch existing profile
      var response = await supabase
          .from('profiles')
          .select('first_name, last_name, name, nickname, email, avatar_url, photo_url, image_url')
          .eq('id', _user!.id)
          .maybeSingle();

      // If no profile row exists yet (first login), create one
      if (response == null) {
        final email = _user!.email ?? '';
        String displayName = '';
        final meta = _user!.userMetadata ?? {};
        try {
          displayName = (meta['full_name'] ?? meta['name'] ?? meta['display_name'] ?? '').toString();
        } catch (_) {}
        if (displayName.isEmpty && email.isNotEmpty) {
          displayName = email.split('@').first;
        }

        String? fName;
        String? lName;
        if (displayName.isNotEmpty) {
          final parts = displayName.trim().split(RegExp(r'\s+'));
          fName = parts.isNotEmpty ? parts.first : null;
          lName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
        }

        try {
          await supabase.from('profiles').upsert({
            'id': _user!.id,
            'email': email,
            'name': displayName.isNotEmpty ? displayName : null,
            'first_name': fName,
            'last_name': lName,
            'avatar_url': (meta['avatar_url'] ?? meta['picture'] ?? meta['photo'] ?? meta['image'])?.toString(),
          });

          // Re-fetch the newly created profile
          response = await supabase
              .from('profiles')
              .select('first_name, last_name, name, nickname, email, avatar_url, photo_url, image_url')
              .eq('id', _user!.id)
              .maybeSingle();
        } catch (e) {
          debugPrint('Error creating profile on first sign-in: $e');
        }
      }

      // Debug log to verify fetched profile data and avatar URL
      debugPrint('Fetched profile: $response');

      _firstName = response?['first_name'] as String?;
      _lastName = response?['last_name'] as String?;
      _email = response?['email'] as String?;

      // Fallback: if first/last are empty, try single 'name' or 'nickname' field
      final String? singleName = (response?['name'] ?? response?['nickname']) as String?;
      if ((_firstName == null || _firstName!.isEmpty) &&
          (_lastName == null || _lastName!.isEmpty) &&
          singleName != null &&
          singleName.isNotEmpty) {
        final parts = singleName.trim().split(RegExp(r'\s+'));
        _firstName = parts.isNotEmpty ? parts.first : null;
        _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
      }

      final dynamic a = response?['avatar_url'] ?? response?['photo_url'] ?? response?['image_url'];
      _avatarUrl = (a is String && a.isNotEmpty) ? a : null;

      debugPrint('Avatar URL loaded: $_avatarUrl');

      // Save the fetched profile to SharedPreferences
      await _saveProfileToPrefs();

      notifyListeners(); // Update UI with new profile info
    } catch (e) {
      debugPrint('Error fetching profile from Supabase: $e');
      // Fallback to load from SharedPreferences
      await _loadProfileFromPrefs();
    }
  }

  // Update avatar in Supabase and notify listeners
  Future<void> setAvatarUrl(String? url) async {
    _avatarUrl = url;
    notifyListeners();
    if (_user == null) return;
    try {
      await supabase.from('profiles').upsert({'id': _user!.id, 'avatar_url': url});
      await _saveProfileToPrefs(); // Save to SharedPreferences
    } catch (_) {}
  }

  // Update full name locally and in Supabase, notify listeners
  Future<void> setFullName(String? fullName) async {
    if (fullName == null) return;
    final parts = fullName.trim().split(RegExp(r'\s+'));
    _firstName = parts.isNotEmpty ? parts.first : null;
    _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    notifyListeners();

    if (_user == null) return;
    try {
      await supabase.from('profiles').upsert({
        'id': _user!.id,
        'first_name': _firstName,
        'last_name': _lastName,
        'name': fullName,
        'nickname': fullName,
        'avatar_url': _avatarUrl,
      });
      await _saveProfileToPrefs(); // Save to SharedPreferences
    } catch (_) {}
  }

  // Update email in Supabase auth and profiles table, notify listeners
  Future<void> updateEmail(String newEmail) async {
    if (_user == null) return;

    try {
      // Update email in Supabase auth
      await supabase.auth.updateUser(UserAttributes(email: newEmail));

      // Refresh the session to ensure user object is updated
      await supabase.auth.refreshSession();

      // Update email in profiles table
      await supabase.from('profiles').upsert({
        'id': _user!.id,
        'email': newEmail,
      });

      // Set email locally
      _email = newEmail;

      // Refresh user object
      _user = supabase.auth.currentUser;

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating email: $e');
      rethrow;
    }
  }

  // Save profile data to SharedPreferences
  Future<void> _saveProfileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', _firstName ?? '');
    await prefs.setString('last_name', _lastName ?? '');
    await prefs.setString('avatar_url', _avatarUrl ?? '');
    await prefs.setString('email', _email ?? '');
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _firstName = prefs.getString('first_name');
    _lastName = prefs.getString('last_name');
    _avatarUrl = prefs.getString('avatar_url');
    _email = prefs.getString('email');
    if (_firstName == '') _firstName = null;
    if (_lastName == '') _lastName = null;
    if (_avatarUrl == '') _avatarUrl = null;
    if (_email == '') _email = null;
    notifyListeners();
  }
}
