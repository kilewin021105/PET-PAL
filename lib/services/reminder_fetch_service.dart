// Service to fetch all reminders from Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder.dart';

Future<List<Reminder>> fetchReminders() async {
  // Query the remindersbadge table for all fields, ordered by date_time
  final response = await Supabase.instance.client
      .from('remindersbadge')
      .select('*')
      .order('date_time', ascending: false);
  // Convert each result to a Reminder object
  return (response as List).map((json) => Reminder.fromJson(json)).toList();
}
