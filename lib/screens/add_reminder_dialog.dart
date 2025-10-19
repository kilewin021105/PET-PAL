import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AddReminderDialog extends StatefulWidget {
  final Map<String, dynamic>? reminder;
  const AddReminderDialog({super.key, this.reminder});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  String? _selectedPetId;
  List<Map<String, dynamic>> _pets = [];

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _fetchPets();

    _titleController = TextEditingController(
      text: widget.reminder?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.reminder?['description'] ?? '',
    );
    _selectedPetId = widget.reminder?['pet_id'];

    final dateTimeStr = widget.reminder?['date_time'] as String?;
    if (dateTimeStr != null) {
      final dt = DateTime.tryParse(dateTimeStr);
      if (dt != null) {
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchPets() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('pets')
        .select('id, name')
        .eq('user_id', userId);

    setState(() {
      _pets = List<Map<String, dynamic>>.from(response);
    });
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
      Random().nextInt(100000), // unique ID
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields, including pet selection.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final reminderData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date_time': dateTime.toIso8601String(),
      'user_id': Supabase.instance.client.auth.currentUser?.id,
      'pet_id': _selectedPetId,
    };

    if (widget.reminder != null && widget.reminder!['id'] != null) {
      await Supabase.instance.client
          .from('remindersbadge')
          .update(reminderData)
          .eq('id', widget.reminder!['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      await Supabase.instance.client
          .from('remindersbadge')
          .insert(reminderData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    await _scheduleNotification(
      dateTime,
      _titleController.text,
      _descriptionController.text,
    );
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop(reminderData);
  }

  Future<void> _removeReminder() async {
    if (widget.reminder == null || widget.reminder!['id'] == null) return;
    setState(() => _isLoading = true);
    await Supabase.instance.client
        .from('remindersbadge')
        .delete()
        .eq('id', widget.reminder!['id']);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder deleted.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop('removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPetId,
                      items: _pets
                          .map(
                            (pet) => DropdownMenuItem<String>(
                              value: pet['id'].toString(),
                              child: Text(pet['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPetId = value),
                      decoration: const InputDecoration(
                        labelText: 'Select Pet',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a pet' : null,
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
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.reminder != null && widget.reminder!['id'] != null)
          TextButton(
            onPressed: _isLoading ? null : _removeReminder,
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: Text(widget.reminder == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
