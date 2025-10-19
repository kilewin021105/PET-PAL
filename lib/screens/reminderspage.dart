import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import 'add_reminder_dialog.dart';
import '../services/reminder_fetch_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reminders found.'));
          }
          final reminders = snapshot.data!;
          return ListView.separated(
            itemCount: reminders.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = reminders[i];
              return ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Colors.teal,
                ),
                title: Text(r.title),
                subtitle: Text(r.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy h:mm a').format(r.dateTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit Reminder',
                      onPressed: () async {
                        // Open dialog for editing
                        final result = await showDialog(
                          context: context,
                          builder: (context) => AddReminderDialog(
                            reminder: {
                              'id': r.id,
                              'title': r.title,
                              'description': r.description,
                              'date_time': r.dateTime.toIso8601String(),
                            },
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _remindersFuture = fetchReminders();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
