import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder.dart';

Future<List<Reminder>> fetchReminders() async {
  final response = await Supabase.instance.client
      .from('remindersbadge')
      .select('*')
      .order('date_time', ascending: false);
  return (response as List)
      .map((json) => Reminder.fromJson(json))
      .toList();
}
