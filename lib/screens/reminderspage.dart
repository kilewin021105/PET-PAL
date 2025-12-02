import 'package:flutter/material.dart';
import '../models/reminder.dart';
import 'add_reminder_dialog.dart';
import '../services/reminder_fetch_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late Future<List<Reminder>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _remindersFuture = fetchReminders();
  }

  void _refreshReminders() {
    setState(() {
      _remindersFuture = fetchReminders();
    });
  }

  String _getDueDateText(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      final daysDifference = reminderDate.difference(today).inDays;
      if (daysDifference > 0 && daysDifference <= 7) {
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return weekdays[reminderDate.weekday - 1];
      } else {
        return '${reminderDate.month}/${reminderDate.day}/${reminderDate.year}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PetPal Reminders"),
        backgroundColor: Colors.teal,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final added = await showDialog(
                context: context,
                builder: (context) => const AddReminderDialog(),
              );
              if (added != null) {
                _refreshReminders();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Reminder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reminders found.'));
          }

          final reminders = snapshot.data!;
          final pending = reminders.where((r) => r.status == 'pending').toList();
          final completed = reminders.where((r) => r.status == 'completed').toList();
          final missed = reminders.where((r) => r.status == 'missed').toList();
          final past = reminders.where((r) => r.status == 'past').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Record Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reminder Record',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('${pending.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                              const Text('Pending'),
                            ],
                          ),
                          Column(
                            children: [
                              Text('${completed.length + missed.length + past.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                              const Text('Past'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Ongoing Reminders
                if (pending.isNotEmpty) ...[
                  const Text('Ongoing Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...pending.map((reminder) => _buildReminderCard(reminder, context)),
                  const SizedBox(height: 24),
                ],

                // Past Reminders
                if ((completed + missed + past).isNotEmpty) ...[
                  const Text('Past Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...(completed + missed + past).map((reminder) => _buildReminderCard(reminder, context)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, BuildContext context) {
    final now = DateTime.now();
    final isToday = reminder.dateTime.toLocal().year == now.year &&
                    reminder.dateTime.toLocal().month == now.month &&
                    reminder.dateTime.toLocal().day == now.day;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDueDateText(reminder.dateTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: reminder.status == 'completed'
                      ? Colors.green.withOpacity(0.15)
                      : (reminder.status == 'missed' || reminder.status == 'past')
                          ? Colors.red.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reminder.status.toUpperCase(),
                  style: TextStyle(
                    color: reminder.status == 'completed'
                        ? Colors.green
                        : (reminder.status == 'missed' || reminder.status == 'past')
                            ? Colors.red
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (reminder.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client
                          .from('remindersbadge')
                          .update({'status': 'completed'})
                          .eq('id', reminder.id)
                          .eq('user_id', userId);
                      _refreshReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder marked as completed')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating reminder: $e')),
                      );
                    }
                  },
                  child: const Text('Mark Completed', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client
                          .from('remindersbadge')
                          .update({'status': 'missed'})
                          .eq('id', reminder.id)
                          .eq('user_id', userId);
                      _refreshReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder marked as missed')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating reminder: $e')),
                      );
                    }
                  },
                  child: const Text('Mark Missed', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          if (reminder.status == 'missed' || reminder.status == 'past') ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final DateTime now = DateTime.now();
                final DateTime initialDate = reminder.dateTime.isBefore(now) ? now : reminder.dateTime;
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(reminder.dateTime),
                  );
                  if (pickedTime != null) {
                    final DateTime newDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client
                          .from('remindersbadge')
                          .update({
                            'status': 'pending',
                            'date_time': newDateTime.toIso8601String()
                          })
                          .eq('id', reminder.id)
                          .eq('user_id', userId);
                      _refreshReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder rescheduled successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error rescheduling reminder: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Reschedule', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ],
      ),
    );
  }
}
