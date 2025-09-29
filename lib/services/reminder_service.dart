import 'package:supabase_flutter/supabase_flutter.dart';

Future<int> getRemindersCount() async {
  final response = await Supabase.instance.client
      .from('remindersbadge')
      .select('id');
  return response.length;
  return 0;
}
