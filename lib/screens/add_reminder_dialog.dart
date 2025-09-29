import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class AddReminderDialog extends StatefulWidget {
  const AddReminderDialog({super.key});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(
    DateTime scheduledDate,
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Channel for reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final reminder = {
        'title': _title,
        'description': _description,
        'date_time': dateTime.toIso8601String(),
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      };
      // TODO: Save reminder to database if needed
      await _scheduleNotification(dateTime, _title, _description);
      setState(() => _isLoading = false);
      if (mounted) Navigator.of(context).pop(reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Reminder'),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Test Notification Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepOrange, width: 1),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Test Notification',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap below to check if notifications are enabled on your device.',
                          style: TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            icon: const Icon(
                              Icons.notifications_active,
                              size: 24,
                            ),
                            label: const Text('SEND TEST NOTIFICATION'),
                            onPressed: () async {
                              await flutterLocalNotificationsPlugin.show(
                                9999,
                                'Test Notification',
                                'If you see this, notifications are working!',
                                const NotificationDetails(
                                  android: AndroidNotificationDetails(
                                    'reminder_channel',
                                    'Reminders',
                                    channelDescription:
                                        'Channel for reminder notifications',
                                    importance: Importance.max,
                                    priority: Priority.high,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: const Text('Open Notification Settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reminder Form
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Title'),
                          onSaved: (value) => _title = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a title' : null,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          onSaved: (value) => _description = value ?? '',
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a description'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _pickDate,
                              child: const Text('Pick Date'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _pickTime,
                              child: const Text('Pick Time'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
