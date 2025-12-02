// Service to get the count of pending reminders from Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

Future<int> getRemindersCount() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return 0;

  // Query the remindersbadge table for pending reminders only
  final response = await Supabase.instance.client
      .from('remindersbadge')
      .select('id')
      .eq('status', 'pending')
      .eq('user_id', userId);
  // Return the number of pending reminders
  return response.length;
}
