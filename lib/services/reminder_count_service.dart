// Service to get the count of reminders from Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

Future<int> getRemindersCount() async {
  // Query the remindersbadge table for all IDs
  final response = await Supabase.instance.client
      .from('remindersbadge')
      .select('id');
  // Return the number of reminders
  return response.length;
}
