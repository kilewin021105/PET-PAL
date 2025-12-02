import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> updatePastReminders() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final now = DateTime.now().toUtc();

  // Update reminders that are 'pending' and date_time < now to 'past'
  await Supabase.instance.client
      .from('remindersbadge')
      .update({'status': 'past'})
      .eq('status', 'pending')
      .eq('user_id', userId)
      .lt('date_time', now.toIso8601String());
}
