// Service to fetch all reminders from Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder.dart';
import 'reminder_update_service.dart';

Future<List<Reminder>> fetchReminders() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  // Update past reminders before fetching
  await updatePastReminders();

  // Query the remindersbadge table for all fields, ordered by date_time
  final response = await Supabase.instance.client
      .from('remindersbadge')
      .select('*')
      .eq('user_id', userId)
      .order('date_time', ascending: true);
  // Convert each result to a Reminder object
  return (response as List).map((json) => Reminder.fromJson(json)).toList();
}
